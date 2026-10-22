#===============================================================================
# KIF: Elite Redux – effects for Elite Redux moves PIF doesn't have, batch 8
# (the last ER-only moves any PIF species learns)
#   Inverse Room     – the type chart is reversed for 5 turns (034's Inverse
#                      Room); used again while it's up, it ends
#   Revival Blessing – a fainted party Pokemon comes back with 1/2 HP. The
#                      player picks it on the party screen, trainers revive
#                      their first one (Cody). Not one still on the field.
#   Doodle           – the user and its allies copy the target's ability and
#                      its innates for the battle (Cody: innates too)
#   Court Change     – swaps every lasting side effect: screens, Tailwind,
#                      hazards, KIF-ER's thorns and caltrops (Cody: everything)
#   Torch Song       – Sp. Atk +1
#   Springtide Storm – Misty Terrain; Smashing Pumpkins – Grassy Terrain
#   Sparkly Swirl    – cures the status of the user's whole party
#   Silk Trap        – Protect; a foe that touches it gets Speed -1 (074)
#   Population Bomb  – hits up to 10 times, each hit can miss (Triple Kick's way)
#   Plasma Pulse     – double power against a status (Hex); 10% paralysis
#   Octolock         – traps the target (Mean Look); its Defense and Sp. Def
#                      -1 at the end of each turn while it stays trapped
#   Mystical Power, Banished Power – the user's highest of Attack, Defense,
#                      Sp. Atk and Sp. Def +1
#   Mirage Slam      – sets a 40 power Future Sight on the target
#   Make It Rain     – hits both foes; the user's Sp. Atk -1; coins (Pay Day)
#   Hydro Steam      – x1.5 in sun instead of halved (Super Hot Flame's way)
#   Dynamax Cannon   – double damage against a Mega
#   Burning Jealousy – 50% burn against a target with any raised stat
#   PIF / earlier classes: Stone Axe (Jagged Punch, 100%), Spine Breaker 007,
#   Ruination 06C, Raging Bull 10A (PIF's Tauros has one form: Normal),
#   Frost Brand 00C (10%; 031 makes it frostbite).
#   Battle AI (both): each is scored as the PIF move it works like.
#===============================================================================
module KIFER
  module NewMoveFx8
    AI_AS = { "KERE01" => "11F", "KERE02" => "000", "KERE03" => "000", "KERE04" => "000",
              "KERE05" => "020", "KERE06" => "000", "KERE07" => "019", "KERE08" => "0AA",
              "KERE09" => "0BF", "KERE10" => "07F", "KERE11" => "0EF", "KERE12" => "000",
              "KERE13" => "111", "KERE14" => "000", "KERE15" => "000", "KERE16" => "000",
              "KERE17" => "000" }

    # side effects Court Change swaps (the lasting ones)
    COURT = [:Reflect, :LightScreen, :AuroraVeil, :Mist, :Safeguard, :Tailwind, :LuckyChant,
             :Spikes, :ToxicSpikes, :StealthRock, :StickyWeb, :Rainbow, :SeaOfFire, :Swamp]
    COURT_IVARS = [:@kifer_mx_thorns, :@kifer_nm3_caltrops, :@kifer_mx_smoke]

    module_function

    def with_allies(user)
      ret = [user]
      user.eachAlly { |b| ret << b }
      return ret
    end

    def court_change(battle)
      a, b = battle.sides[0], battle.sides[1]
      COURT.each do |name|
        next if !PBEffects.const_defined?(name)
        e = PBEffects.const_get(name)
        a.effects[e], b.effects[e] = b.effects[e], a.effects[e]
      end
      COURT_IVARS.each do |iv|
        x, y = a.instance_variable_get(iv), b.instance_variable_get(iv)
        a.instance_variable_set(iv, y)
        b.instance_variable_set(iv, x)
      end
    end

    # party indexes Revival Blessing can bring back
    def revivable(battle, user)
      party = battle.pbParty(user.index)
      on_field = battle.battlers.select { |b| b && !b.opposes?(user) }.map { |b| b.pokemon }   # fainted ones too
      return party.each_index.select do |i|
        p = party[i]
        p && !p.egg? && p.fainted? && on_field.none? { |q| q.equal?(p) }
      end
    end

    def pick_revive(battle, user, list)
      return list.first if list.length <= 1 || !battle.pbOwnedByPlayer?(user.index)
      party = battle.pbParty(user.index)
      ret = nil
      pbFadeOutIn {
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, party)
        screen.pbStartScene(_INTL("Choose a fainted Pokémon to revive."), false)
        loop do
          i = screen.pbChoosePokemon
          if i && list.include?(i)
            ret = i
            break
          end
          screen.pbDisplay(_INTL("Choose a Pokémon that has fainted."))
        end
        screen.pbEndScene
      }
      return ret || list.first
    end

    # Mirage Slam's Future Sight hits at 40 power
    def mirage?(battle, idx)
      return battle.positions[idx] && battle.positions[idx].instance_variable_get(:@kifer_nm8_mirage)
    end
  end
end

class PokeBattle_Move_KERE01 < PokeBattle_Move   # Inverse Room
  def pbMoveFailed?(user, targets)
    return false if KIFER.feature_on?(:inverse_room)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    if KIFER::Specials1.inverse_room?(@battle)
      @battle.instance_variable_set(:@kifer_sp1_inverse, 0)
      @battle.pbDisplay(_INTL("Type matchups returned to normal!"))
    else
      @battle.instance_variable_set(:@kifer_sp1_inverse, 5)
      @battle.pbDisplay(_INTL("{1} reversed the type matchups!", user.pbThis))
    end
  end
end

class PokeBattle_Move_KERE02 < PokeBattle_Move   # Revival Blessing
  def pbMoveFailed?(user, targets)
    return false if !KIFER::NewMoveFx8.revivable(@battle, user).empty?
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    list = KIFER::NewMoveFx8.revivable(@battle, user)
    i = KIFER::NewMoveFx8.pick_revive(@battle, user, list)
    p = @battle.pbParty(user.index)[i]
    return if !p
    p.heal_status
    p.hp = [(p.totalhp / 2.0).floor, 1].max
    @battle.pbDisplay(_INTL("{1} was revived and is ready to fight again!", p.name))
  end
end

class PokeBattle_Move_KERE03 < PokeBattle_Move   # Doodle
  def pbFailsAgainstTarget?(user, target)
    if !target.ability || target.ungainableAbility? ||
       KIFER::NewMoveFx8.with_allies(user).all? { |b| b.unstoppableAbility? }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    KIFER::NewMoveFx8.with_allies(user).each do |b|
      next if b.unstoppableAbility?
      b.ability = target.ability
      b.instance_variable_set(:@innate_ids, Array(target.innate_ids).dup)
      @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!", b.pbThis, target.pbThis(true), target.abilityName))
    end
  end
end

class PokeBattle_Move_KERE04 < PokeBattle_Move   # Court Change
  def pbEffectGeneral(user)
    KIFER::NewMoveFx8.court_change(@battle)
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!", user.pbThis))
  end
end

class PokeBattle_Move_KERE05 < PokeBattle_Move   # Torch Song
  def pbAdditionalEffect(user, target)
    return if user.fainted?
    user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
  end
end

class PokeBattle_Move_KERE06 < PokeBattle_Move   # Springtide Storm, Smashing Pumpkins
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    t = (@id == :SMASHINGPUMPKINS) ? :Grassy : :Misty
    @battle.pbStartTerrain(user, t) if @battle.field.terrain != t
  end
end

class PokeBattle_Move_KERE07 < PokeBattle_Move   # Sparkly Swirl
  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    return if @battle.instance_variable_get(:@kifer_nm8_swirl) == @battle.turnCount   # once per use
    @battle.instance_variable_set(:@kifer_nm8_swirl, @battle.turnCount)
    @battle.eachSameSideBattler(user) { |b| b.pbCureStatus(false) if b.status != :NONE }
    @battle.pbParty(user.index).each { |p| p.heal_status if p && !p.egg? && p.status != :NONE }
    @battle.pbDisplay(_INTL("A bell chimed!"))
  end
end

class PokeBattle_Move_KERE08 < PokeBattle_Move_KERD72   # Silk Trap
  def kifer_guard; return :silk; end
end

class PokeBattle_Move_KERE09 < PokeBattle_Move   # Population Bomb
  def multiHitMove?; return true; end
  def pbNumHits(user, targets); return 10; end
  def successCheckPerHit?; return @kifer_per_hit; end

  def pbOnStartUse(user, targets)
    @kifer_per_hit = !user.hasActiveAbility?(:SKILLLINK)
  end
end

class PokeBattle_Move_KERE10 < PokeBattle_Move_07F   # Plasma Pulse
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
  end
end

class PokeBattle_Move_KERE11 < PokeBattle_Move   # Octolock
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted? || target.damageState.unaffected || target.damageState.substitute
    return if target.effects[PBEffects::MeanLook] >= 0
    target.effects[PBEffects::MeanLook] = user.index
    target.instance_variable_set(:@kifer_nm8_octo, true)
    @battle.pbDisplay(_INTL("{1} can no longer escape!", target.pbThis))
  end
end

class PokeBattle_Move_KERE12 < PokeBattle_Move   # Mystical Power, Banished Power
  def pbAdditionalEffect(user, target)
    return if user.fainted?
    s = KIFER::BatchD.highest_stat(user, [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE])
    user.pbRaiseStatStage(s, 1, user) if user.pbCanRaiseStatStage?(s, user, self)
  end
end

class PokeBattle_Move_KERE13 < PokeBattle_Move   # Mirage Slam
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.unaffected
    pos = @battle.positions[target.index]
    return if !pos || pos.effects[PBEffects::FutureSightCounter] > 0
    pos.effects[PBEffects::FutureSightCounter]        = 3
    pos.effects[PBEffects::FutureSightMove]           = :FUTURESIGHT
    pos.effects[PBEffects::FutureSightUserIndex]      = user.index
    pos.effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
    pos.instance_variable_set(:@kifer_nm8_mirage, true)
    @battle.pbDisplay(_INTL("{1} foresaw an attack!", user.pbThis))
  end
end

class PokeBattle_Move_KERE14 < PokeBattle_Move   # Make It Rain
  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    @battle.field.effects[PBEffects::PayDay] += 5 * user.level if user.pbOwnedByPlayer?
    return if user.fainted? || @battle.instance_variable_get(:@kifer_nm8_rain) == @battle.turnCount   # once per use
    @battle.instance_variable_set(:@kifer_nm8_rain, @battle.turnCount)
    @battle.pbDisplay(_INTL("Coins were scattered everywhere!")) if user.pbOwnedByPlayer?
    user.pbLowerStatStage(:SPECIAL_ATTACK, 1, user) if user.pbCanLowerStatStage?(:SPECIAL_ATTACK, user, self)
  end
end

class PokeBattle_Move_KERE15 < PokeBattle_Move   # Hydro Steam
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    super
    multipliers[:final_damage_multiplier] *= 3 if type == :WATER && @battle.pbWeather == :Sun   # /2 -> x1.5
  end
end

class PokeBattle_Move_KERE16 < PokeBattle_Move   # Dynamax Cannon
  def pbBaseDamage(baseDmg, user, target)
    return target.mega? ? baseDmg * 2 : baseDmg
  end
end

class PokeBattle_Move_KERE17 < PokeBattle_Move   # Burning Jealousy
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute || !target.stages.values.any? { |v| v > 0 }
    return if @battle.pbRandom(100) >= 50
    target.pbBurn(user) if target.pbCanBurn?(user, false, self)
  end
end

# Mirage Slam: its Future Sight hits at 40 power
class PokeBattle_Move_111
  alias kifer_nm8_pbBaseDamage pbBaseDamage unless method_defined?(:kifer_nm8_pbBaseDamage)
  def pbBaseDamage(baseDmg, user, target)
    return 40 if @battle.futureSight && target && KIFER::NewMoveFx8.mirage?(@battle, target.index)
    return kifer_nm8_pbBaseDamage(baseDmg, user, target)
  end
end

class PokeBattle_Battler
  alias kifer_nm8_pbInitEffects pbInitEffects unless method_defined?(:kifer_nm8_pbInitEffects)
  def pbInitEffects(batonPass)
    kifer_nm8_pbInitEffects(batonPass)
    @kifer_nm8_octo = false
  end
end

class PokeBattle_Battle
  alias kifer_nm8_pbEndOfRoundPhase pbEndOfRoundPhase unless method_defined?(:kifer_nm8_pbEndOfRoundPhase)
  def pbEndOfRoundPhase
    # Octolock: while the trapper is still out
    pbPriority(true).each do |b|
      next if b.fainted? || !b.instance_variable_get(:@kifer_nm8_octo)
      if b.effects[PBEffects::MeanLook] < 0
        b.instance_variable_set(:@kifer_nm8_octo, false)
        next
      end
      t = @battlers[b.effects[PBEffects::MeanLook]]
      anim = true
      [:DEFENSE, :SPECIAL_DEFENSE].each do |s|
        next if !b.pbCanLowerStatStage?(s, t)
        anim = false if b.pbLowerStatStage(s, 1, t, anim)
      end
    end
    kifer_nm8_pbEndOfRoundPhase
    # a spent Future Sight is a normal one again
    @positions.each do |pos|
      next if !pos || pos.effects[PBEffects::FutureSightCounter] > 0
      pos.instance_variable_set(:@kifer_nm8_mirage, false)
    end
  end
end

class PokeBattle_AI
  alias kifer_nmf8_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode unless method_defined?(:kifer_nmf8_pbGetMoveScoreFunctionCode)
  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    f = move && move.function
    as = KIFER::NewMoveFx8::AI_AS[f]
    return kifer_nmf8_pbGetMoveScoreFunctionCode(score, move, user, target, skill) if !as
    move.instance_variable_set(:@function, as)   # scored as the PIF move it works like
    begin
      return kifer_nmf8_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    ensure
      move.instance_variable_set(:@function, f)
    end
  end
end

KIFER::NewMoveFx8::AI_AS.each_key do |c|
  k = Object.const_get("PokeBattle_Move_#{c}")
  KIFER::TerrainEnrage.wrap_move_class(k) if defined?(KIFER::TerrainEnrage) && KIFER::TerrainEnrage.respond_to?(:wrap_move_class)
end

KIFER::Moves.coded(:INVERSEROOM, function_code: "KERE01")
KIFER::Moves.coded(:REVIVALBLESSING, function_code: "KERE02")
KIFER::Moves.coded(:DOODLE, function_code: "KERE03")
KIFER::Moves.coded(:COURTCHANGE, function_code: "KERE04")
KIFER::Moves.coded(:TORCHSONG, function_code: "KERE05")
KIFER::Moves.coded(:SPRINGTIDESTORM, :SMASHINGPUMPKINS, function_code: "KERE06")
KIFER::Moves.coded(:SPARKLYSWIRL, function_code: "KERE07")
KIFER::Moves.coded(:SILKTRAP, function_code: "KERE08")
KIFER::Moves.coded(:POPULATIONBOMB, function_code: "KERE09")
KIFER::Moves.coded(:PLASMAPULSE, function_code: "KERE10")
KIFER::Moves.coded(:OCTOLOCK, function_code: "KERE11")
KIFER::Moves.coded(:MYSTICALPOWER, :BANISHEDPOWER, function_code: "KERE12")
KIFER::Moves.coded(:MIRAGESLAM, function_code: "KERE13")
KIFER::Moves.coded(:MAKEITRAIN, function_code: "KERE14")
KIFER::Moves.coded(:HYDROSTEAM, function_code: "KERE15")
KIFER::Moves.coded(:DYNAMAXCANNON, function_code: "KERE16")
KIFER::Moves.coded(:BURNINGJEALOUSY, function_code: "KERE17")
KIFER::Moves.coded(:STONEAXE, function_code: "KERD46")
KIFER::Moves.coded(:SPINEBREAKER, function_code: "007")
KIFER::Moves.coded(:RUINATION, function_code: "06C")
KIFER::Moves.coded(:RAGINGBULL, function_code: "10A")
KIFER::Moves.coded(:FROSTBRAND, function_code: "00C", chance: 10)   # ER text: 10% frostbite (the ROM chance is 0)
KIFER::NewMoves.register   # in the game now (064)
