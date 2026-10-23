#===============================================================================
# The abilities of Z-A's new Megas that PIF doesn't have, working as in Z-A /
# Pokémon Champions (Cody: "Create the ability that they use in Z-A"):
#   Mega Sol    (Mega Meganium)   its moves act as if the weather were harsh sunlight
#   Aura Guard  (Mega Lucario Z)  contact moves deal it half damage
#   Sharpness   (Mega Absol Z)    slicing moves x1.5
#   Unseen Fist (Mega Golurk)     contact moves hit through Protect and the like
#   Eelevate    (Mega Eelektross) floats (Ground immunity, no hazards) and
#                                 raises its best stat when it knocks out a foe
#   Stalwart    (Mega Skarmory)   its moves can't be drawn away (Follow Me,
#                                 Rage Powder, Spotlight, Lightning Rod, Storm Drain)
# One another mod already registered is left alone (handlers included): with
# KIF-ER's Innates on, its Elite Redux versions are used. With KIF-ER installed
# but Innates off, Megas' Z-A versions run (Cody, 2026-10-19: "without KIF:ER:
# official ability"; KIF-ER's own handlers stand down then).
#===============================================================================
module Megas
  ABILITY_ID_BASE = 8500 unless defined?(ABILITY_ID_BASE)   # KIF-ER uses 9000+
  ABILITIES = {
    :MEGASOL    => ["Mega Sol",    "Its moves act as if the weather were harsh sunlight."],
    :AURAGUARD  => ["Aura Guard",  "Halves the damage taken from contact moves."],
    :SHARPNESS  => ["Sharpness",   "Powers up slicing moves."],
    :UNSEENFIST => ["Unseen Fist", "Contact moves hit through the target's protection."],
    :EELEVATE   => ["Eelevate",    "Floats. Its best stat rises when it knocks out a foe."],
    :STALWART   => ["Stalwart",    "Ignores moves and abilities that draw in moves."]
  } unless defined?(ABILITIES)
  # Slicing moves (Gen 9 list); ones PIF doesn't have are simply never used
  SLICING = [:AERIALACE, :AIRCUTTER, :AIRSLASH, :AQUACUTTER, :BEHEMOTHBLADE, :BITTERBLADE,
             :CEASELESSEDGE, :CROSSPOISON, :CUT, :FURYCUTTER, :KOWTOWCLEAVE, :LEAFBLADE,
             :MIGHTYCLEAVE, :NIGHTSLASH, :POPULATIONBOMB, :PSYBLADE, :PSYCHOCUT, :RAZORLEAF,
             :RAZORSHELL, :SACREDSWORD, :SECRETSWORD, :SLASH, :SOLARBLADE, :STONEAXE,
             :TACHYONCUTTER, :XSCISSOR] unless defined?(SLICING)

  def self.own_ability?(id)
    a = GameData::Ability::DATA[id]
    return a && a.instance_variable_get(:@megas_own) == true
  end

  # Does Megas' own (Z-A) version of this ability run right now?
  def self.za_on?(id)
    return true if own_ability?(id)
    return defined?(::KIFER) && GameData::Ability::DATA.key?(id) && !er? ? true : false
  end

  def self.register_abilities
    ABILITIES.each_with_index do |(id, (name, desc)), i|
      next if GameData::Ability::DATA[id] && !own_ability?(id)
      n = ABILITY_ID_BASE + i
      GameData::Ability.register({ :id => id, :id_number => n, :name => name, :description => desc })
      GameData::Ability::DATA[id].instance_variable_set(:@megas_own, true)
      MessageTypes.set(MessageTypes::Abilities, n, name)
      MessageTypes.set(MessageTypes::AbilityDescs, n, desc)
    end
    register_ability_handlers
  end

  def self.register_ability_handlers
    if own_ability?(:AURAGUARD)
      BattleHandlers::DamageCalcTargetAbility.add(:AURAGUARD,
        proc { |_ability, user, _target, move, mults, _baseDmg, _type|
          mults[:final_damage_multiplier] *= 0.5 if move.pbContactMove?(user)
        })
    end
    if own_ability?(:SHARPNESS)
      BattleHandlers::DamageCalcUserAbility.add(:SHARPNESS,
        proc { |_ability, _user, _target, move, mults, _baseDmg, _type|
          mults[:base_damage_multiplier] *= 1.5 if SLICING.include?(move.id)
        })
    end
    BattleHandlers::UserAbilityEndOfMove.copy(:BEASTBOOST, :EELEVATE) if own_ability?(:EELEVATE)
  end
end

KIF::DataLoad.after_load_all("Megas: abilities") { Megas.register_abilities }
Megas.register_abilities if GameData::Ability::DATA.key?(:OVERGROW)   # data already loaded (reload, tests)

# Mega Sol and Unseen Fist need to know whose move is running
class PokeBattle_Battle
  attr_accessor :megas_user   # the battler using a move right now (nil between moves)
  attr_accessor :megas_view   # who a weather check is for during a Mega Sol move (nil: the move itself)

  # Mega Sol (Cody, 2026-10-22): during its own move, that move and the user's
  # own checks see harsh sunlight whatever the weather is; the target and
  # everyone else see the real weather (Desolate Land's sun is left alone)
  alias megas_pbWeather pbWeather unless method_defined?(:megas_pbWeather)
  def pbWeather
    w = megas_pbWeather
    return :Sun if @megas_sun && w != :HarshSun && (@megas_view.nil? || @megas_view.equal?(@megas_user))
    return w
  end
end

module Megas
  SOL_OTHER = Object.new.freeze unless defined?(SOL_OTHER)   # "someone other than the user"
  class << self
    attr_accessor :sol_battle   # the battle while a Mega Sol move runs, else nil
  end

  # Who a battle handler checks the weather for, from its name and arguments
  def self.sol_view(name, args)
    return SOL_OTHER if name.include?("Target") || name.include?("Ally") || name.include?("Bearer")
    return nil if name.include?("User")
    return args.find { |a| a.is_a?(PokeBattle_Battler) }
  end

  # Runs the block with the weather checked for `view`
  def self.sol_as(view)
    b = sol_battle
    return yield if !b
    was = b.megas_view
    b.megas_view = view
    begin
      return yield
    ensure
      b.megas_view = was
    end
  end
end

# Ability and item handlers say whose check it is. The user's own ("User...",
# not "UserAlly...") need nothing: no mark means the user. Plain methods (not
# define_method + send): these run often in every battle.
BattleHandlers.singleton_methods.grep(/\Atrigger/).each do |name|
  str = name.to_s
  next if str.include?("User") && !str.include?("UserAlly")
  orig = "megas_sol_#{str}"
  sc = BattleHandlers.singleton_class
  sc.send(:alias_method, orig, name) unless sc.method_defined?(orig)
  sc.class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
    def #{str}(*args, &blk)
      return #{orig}(*args, &blk) if !Megas.sol_battle
      Megas.sol_as(Megas.sol_view("#{str}", args)) { #{orig}(*args, &blk) }
    end
  RUBY
end

class PokeBattle_Battler
  # a battler's own weather checks: status immunity (no freezing in sun), weather forms
  %i[pbCanInflictStatus? pbCheckFormOnWeatherChange].each do |m|
    orig = :"megas_sol_#{m}"
    alias_method orig, m unless method_defined?(orig)
    define_method(m) do |*args, &blk|
      return send(orig, *args, &blk) if !Megas.sol_battle
      Megas.sol_as(self) { send(orig, *args, &blk) }
    end
  end

  alias megas_za_pbUseMove pbUseMove unless method_defined?(:megas_za_pbUseMove)
  def pbUseMove(*args, &blk)
    prev_user, prev_sun, prev_battle = @battle.megas_user, @battle.instance_variable_get(:@megas_sun), Megas.sol_battle
    @battle.megas_user = self
    sun = Megas.za_on?(:MEGASOL) && hasActiveAbility?(:MEGASOL)
    @battle.instance_variable_set(:@megas_sun, sun)
    Megas.sol_battle = sun ? @battle : nil
    return megas_za_pbUseMove(*args, &blk)
  ensure
    @battle.megas_user = prev_user
    @battle.instance_variable_set(:@megas_sun, prev_sun)
    Megas.sol_battle = prev_battle
  end

  # Eelevate floats like Levitate (Iron Ball, Ingrain, Smack Down and Gravity still ground it)
  alias megas_airborne? airborne? unless method_defined?(:megas_airborne?)
  def airborne?
    return true if megas_airborne?
    # runs for every grounded battler: only Mega Eelektross has Eelevate (its
    # own ability, never an innate), so a cheap look first
    return false if @ability_id != :EELEVATE
    return false if hasActiveItem?(:IRONBALL) || @effects[PBEffects::Ingrain] ||
                    @effects[PBEffects::SmackDown] || @battle.field.effects[PBEffects::Gravity] > 0
    return Megas.za_on?(:EELEVATE) && hasActiveAbility?(:EELEVATE) && !@battle.moldBreaker
  end
end

class PokeBattle_Battler
  # Stalwart: its moves keep their target
  alias megas_pbChangeTargets pbChangeTargets unless method_defined?(:megas_pbChangeTargets)
  def pbChangeTargets(move, user, targets)
    return targets if user && Megas.za_on?(:STALWART) && user.hasActiveAbility?(:STALWART)
    return megas_pbChangeTargets(move, user, targets)
  end
end

class PokeBattle_Move
  # Unseen Fist: contact moves ignore Protect, Detect, King's Shield and the like
  alias megas_canProtectAgainst? canProtectAgainst? unless method_defined?(:megas_canProtectAgainst?)
  def canProtectAgainst?
    u = @battle.megas_user
    return false if u && Megas.za_on?(:UNSEENFIST) && u.hasActiveAbility?(:UNSEENFIST) && pbContactMove?(u)
    return megas_canProtectAgainst?
  end
end
