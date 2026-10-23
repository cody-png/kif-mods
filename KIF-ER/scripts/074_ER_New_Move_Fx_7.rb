#===============================================================================
# KIF: Elite Redux – effects for Elite Redux moves PIF doesn't have, batch 7
#   Burning Bulwark – Protect; a foe that touches it is burned
#   Obstruct        – Protect; a foe that touches it gets Defense -2
#   Dire Claw       – 50%: paralysis, poison or bleeding (one, at random)
#   Transmute       – if it knocks the target out, the user gets back the item
#                     it used up (Recycle)
#   Chilly Reception – starts hail, then the user switches out
#   Grav Apple      – the target's Defense -1; x1.5 under Gravity
#   Clangorous Soul – costs 1/3 max HP: all stats +1
#   Behemoth Bash   – Body Press (067); double damage against a Mega
#   Take Heart      – cures the user's status; Sp. Atk and Sp. Def +1
#   Rage Fist       – +20 power per hit the user took this battle, up to +120
#                     (Cody: switching out doesn't reset it)
#   Bitter Malice   – 30% frostbite (PIF's freeze class, 031 turns it into
#                     frostbite); x1.5 against a target with a status
#   Salt Cure       – the target loses 1/8 max HP each turn (1/4 if Water or
#                     Steel) until it leaves the field
#   Sandsear Storm  – starts a sandstorm
#   Sappy Seed      – Leech Seed on the target; Bramble Blast – 30% Leech Seed
#   Ceaseless Edge  – a layer of Spikes on the target's side (Cody: ER's
#                     "Splinters" are never explained)
#   Spicy Extract   – the target's Attack +2 and Defense -2
#   Bolt Beak, Fishious Rend – double power if the target hasn't moved yet
#   Glitzy Glow     – sets Light Screen on the user's side
#   Kilobite        – the target's Speed -1, or the user's Speed +1 if it can't
#   Axe Kick        – 30% confusion; crash damage on a miss (Hi Jump Kick)
#   Fickle Beam     – 30%: double power
#   Fillet Away     – costs 1/2 max HP: Attack, Sp. Atk and Speed +2
#   Viral Strike    – hands the user's status to the target (Psycho Shift)
#   Drake Missile   – hits both foes (its target, no class of its own)
#   PIF classes: Lightning Strike 01F (20% Speed +1), Wild Swing 0EC,
#   Comeuppance 073, Giant Gale 03E, Rider Kick 163, Tachyon Cutter 0BD,
#   Flower Trick 0A0. Batch 5/6 classes: Lunar Blessing, Squeaky Hammer.
#   Battle AI (both): each is scored as the PIF move it works like.
#===============================================================================
module KIFER
  module NewMoveFx7
    AI_AS = { "KERD72" => "0AA", "KERD73" => "0AA", "KERD74" => "000", "KERD75" => "000",
              "KERD76" => "0EE", "KERD77" => "043", "KERD78" => "02D", "KERD79" => "000",
              "KERD80" => "000", "KERD81" => "000", "KERD82" => "00C", "KERD83" => "000",
              "KERD84" => "000", "KERD85" => "0DC", "KERD86" => "000", "KERD87" => "000",
              "KERD88" => "000", "KERD89" => "000", "KERD90" => "000", "KERD91" => "10B",
              "KERD92" => "000", "KERD93" => "02D", "KERD94" => "01B" }

    module_function

    def hits(battle)
      return battle.instance_variable_get(:@kifer_nm7_hits) || battle.instance_variable_set(:@kifer_nm7_hits, {})
    end

    def start_weather(battle, user, weather)
      return if battle.field.weather == weather || [:HeavyRain, :HarshSun, :StrongWinds].include?(battle.field.weather)
      battle.pbStartWeather(user, weather, true, false)
    end

    # A Protect variant stopped a contact move this round
    def guard_hit(battle, user, target, move)
      g = target.instance_variable_get(:@kifer_nm7_guard)
      return if !g || g[1] != battle.turnCount || !target.damageState.protected
      return if user.fainted? || !move.pbContactMove?(user) || !user.affectedByContactEffect?
      case g[0]
      when :burn
        user.pbBurn(target) if user.pbCanBurn?(target, false)
      when :obstruct
        user.pbLowerStatStage(:DEFENSE, 2, target) if user.pbCanLowerStatStage?(:DEFENSE, target)
      when :silk   # Silk Trap (075)
        user.pbLowerStatStage(:SPEED, 1, target) if user.pbCanLowerStatStage?(:SPEED, target)
      end
    end
  end
end

class PokeBattle_Move_KERD72 < PokeBattle_ProtectMove   # Burning Bulwark
  def initialize(battle, move)
    super
    @effect = PBEffects::Protect
  end

  def kifer_guard; return :burn; end

  def pbEffectGeneral(user)
    super
    user.instance_variable_set(:@kifer_nm7_guard, [kifer_guard, @battle.turnCount])
  end
end

class PokeBattle_Move_KERD73 < PokeBattle_Move_KERD72   # Obstruct
  def kifer_guard; return :obstruct; end
end

class PokeBattle_Move_KERD74 < PokeBattle_Move   # Dire Claw
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0 then target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    when 1 then target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    else
      target.pbBleed(user) if KIFER.feature_on?(:bleeding) && target.pbCanBleed?(user, false, self)
    end
  end
end

class PokeBattle_Move_KERD75 < PokeBattle_Move   # Transmute
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || !target.fainted? || user.item || !user.recycleItem
    item = user.recycleItem
    user.item = item
    user.setInitialItem(item) if @battle.wildBattle? && !user.initialItem
    user.setRecycleItem(nil)
    user.effects[PBEffects::PickupItem] = nil
    user.effects[PBEffects::PickupUse]  = 0
    @battle.pbDisplay(_INTL("{1} found one {2}!", user.pbThis, user.itemName))
  end
end

class PokeBattle_Move_KERD76 < PokeBattle_Move   # Chilly Reception
  def pbEffectGeneral(user)
    @battle.pbDisplay(_INTL("{1} is preparing to tell a chillingly bad joke!", user.pbThis))
    KIFER::NewMoveFx7.start_weather(@battle, user, :Hail)
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    KIFER::Fx.switch_out(@battle, user, switchedBattlers)
  end
end

class PokeBattle_Move_KERD77 < PokeBattle_Move   # Grav Apple
  def pbBaseDamage(baseDmg, user, target)
    return @battle.field.effects[PBEffects::Gravity] > 0 ? (baseDmg * 1.5).round : baseDmg
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbLowerStatStage(:DEFENSE, 1, user) if target.pbCanLowerStatStage?(:DEFENSE, user, self)
  end
end

class PokeBattle_Move_KERD78 < PokeBattle_MultiStatUpMove   # Clangorous Soul
  def initialize(battle, move)
    super
    @statUp = [:ATTACK, 1, :DEFENSE, 1, :SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1]
  end

  def kifer_cost(user); return [(user.totalhp / 3.0).floor, 1].max; end

  def pbMoveFailed?(user, targets)
    if user.hp <= kifer_cost(user)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    user.pbReduceHP(kifer_cost(user), false)
    user.pbItemHPHealCheck
    super
  end
end

class PokeBattle_Move_KERD79 < PokeBattle_Move_KERD03   # Behemoth Bash
  def pbBaseDamage(baseDmg, user, target)
    ret = super
    return target.mega? ? ret * 2 : ret
  end
end

class PokeBattle_Move_KERD80 < PokeBattle_MultiStatUpMove   # Take Heart
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1]
  end

  def pbMoveFailed?(user, targets)
    return false if user.status != :NONE
    return super
  end

  def pbEffectGeneral(user)
    user.pbCureStatus if user.status != :NONE
    super
  end
end

class PokeBattle_Move_KERD81 < PokeBattle_Move   # Rage Fist
  def pbBaseDamage(baseDmg, user, target)
    n = KIFER::NewMoveFx7.hits(@battle)[user.pokemon.object_id].to_i
    return baseDmg + 20 * [n, 6].min
  end
end

class PokeBattle_Move_KERD82 < PokeBattle_Move_00C   # Bitter Malice
  def pbBaseDamage(baseDmg, user, target)
    return target.status != :NONE ? (baseDmg * 1.5).round : baseDmg
  end
end

class PokeBattle_Move_KERD83 < PokeBattle_Move   # Salt Cure
  def pbEffectAgainstTarget(user, target)
    return if target.fainted? || target.damageState.unaffected || target.damageState.substitute
    return if target.instance_variable_get(:@kifer_nm7_salt)
    target.instance_variable_set(:@kifer_nm7_salt, true)
    @battle.pbDisplay(_INTL("{1} is being salt cured!", target.pbThis))
  end
end

class PokeBattle_Move_KERD84 < PokeBattle_Move   # Sandsear Storm
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    KIFER::NewMoveFx7.start_weather(@battle, user, :Sandstorm)
  end
end

class PokeBattle_Move_KERD85 < PokeBattle_Move   # Sappy Seed (always), Bramble Blast (its chance)
  def pbEffectAgainstTarget(user, target)
    return if @id != :SAPPYSEED || target.damageState.unaffected || target.damageState.substitute
    KIFER::Fx.leech_seed(@battle, user, target)
  end

  def pbAdditionalEffect(user, target)
    return if @id == :SAPPYSEED || target.damageState.substitute
    KIFER::Fx.leech_seed(@battle, user, target)
  end
end

class PokeBattle_Move_KERD86 < PokeBattle_Move   # Ceaseless Edge
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.unaffected
    side = target.pbOwnSide
    return if side.effects[PBEffects::Spikes] >= 3
    side.effects[PBEffects::Spikes] += 1
    @battle.pbDisplay(_INTL("Spikes were scattered all around {1}'s feet!", user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_KERD87 < PokeBattle_Move   # Spicy Extract
  def pbFailsAgainstTarget?(user, target)
    return false if target.pbCanRaiseStatStage?(:ATTACK, user, self) || target.pbCanLowerStatStage?(:DEFENSE, user, self)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectAgainstTarget(user, target)
    target.pbRaiseStatStage(:ATTACK, 2, user) if target.pbCanRaiseStatStage?(:ATTACK, user, self)
    target.pbLowerStatStage(:DEFENSE, 2, user) if target.pbCanLowerStatStage?(:DEFENSE, user, self)
  end
end

class PokeBattle_Move_KERD88 < PokeBattle_Move   # Bolt Beak, Fishious Rend
  def pbBaseDamage(baseDmg, user, target)
    return target.movedThisRound? ? baseDmg : baseDmg * 2
  end
end

class PokeBattle_Move_KERD89 < PokeBattle_Move   # Glitzy Glow
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    KIFER::Fx.screen(@battle, user, PBEffects::LightScreen, _INTL("Light Screen"))
  end
end

class PokeBattle_Move_KERD90 < PokeBattle_Move   # Kilobite
  def pbAdditionalEffect(user, target)
    if !target.damageState.substitute && target.pbCanLowerStatStage?(:SPEED, user, self)
      target.pbLowerStatStage(:SPEED, 1, user)
    elsif !user.fainted? && user.pbCanRaiseStatStage?(:SPEED, user, self)
      user.pbRaiseStatStage(:SPEED, 1, user)
    end
  end
end

class PokeBattle_Move_KERD91 < PokeBattle_Move_10B   # Axe Kick
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbConfuse if target.pbCanConfuse?(user, false, self)
  end
end

class PokeBattle_Move_KERD92 < PokeBattle_Move   # Fickle Beam
  def pbOnStartUse(user, targets)
    @kifer_all_out = @battle.pbRandom(100) < 30
    @battle.pbDisplay(_INTL("{1} is going all out for this attack!", user.pbThis)) if @kifer_all_out
  end

  def pbBaseDamage(baseDmg, user, target)
    return @kifer_all_out ? baseDmg * 2 : baseDmg
  end
end

class PokeBattle_Move_KERD93 < PokeBattle_MultiStatUpMove   # Fillet Away
  def initialize(battle, move)
    super
    @statUp = [:ATTACK, 2, :SPECIAL_ATTACK, 2, :SPEED, 2]
  end

  def kifer_cost(user); return [(user.totalhp / 2.0).floor, 1].max; end

  def pbMoveFailed?(user, targets)
    if user.hp <= kifer_cost(user)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    user.pbReduceHP(kifer_cost(user), false)
    user.pbItemHPHealCheck
    super
  end
end

class PokeBattle_Move_KERD94 < PokeBattle_Move   # Viral Strike
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted? || target.damageState.unaffected || target.damageState.substitute
    return if !KIFER::MoveFxField.bestow_status?(user, target, self)
    KIFER::MoveFxField.pass_status(@battle, user, target)
  end
end

# Rage Fist: hits each Pokemon took this battle
class PokeBattle_Move
  alias kifer_nm7_pbInflictHPDamage pbInflictHPDamage unless method_defined?(:kifer_nm7_pbInflictHPDamage)
  def pbInflictHPDamage(target)
    kifer_nm7_pbInflictHPDamage(target)
    return if target.damageState.substitute || target.damageState.hpLost <= 0 || !target.pokemon
    h = KIFER::NewMoveFx7.hits(@battle)
    h[target.pokemon.object_id] = h[target.pokemon.object_id].to_i + 1
  end
end

# Burning Bulwark / Obstruct: after Protect stops a contact move
class PokeBattle_Battler
  alias kifer_nm7_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget unless method_defined?(:kifer_nm7_pbSuccessCheckAgainstTarget)
  def pbSuccessCheckAgainstTarget(move, user, target)
    ret = kifer_nm7_pbSuccessCheckAgainstTarget(move, user, target)
    KIFER::NewMoveFx7.guard_hit(@battle, user, target, move) if !ret
    return ret
  end

  # Salt Cure ends when the Pokemon leaves the field
  alias kifer_nm7_pbInitEffects pbInitEffects unless method_defined?(:kifer_nm7_pbInitEffects)
  def pbInitEffects(batonPass)
    kifer_nm7_pbInitEffects(batonPass)
    @kifer_nm7_salt = false
    @kifer_nm7_guard = nil
  end
end

# Salt Cure's damage, first thing at the end of the round
class PokeBattle_Battle
  alias kifer_nm7_pbEndOfRoundPhase pbEndOfRoundPhase unless method_defined?(:kifer_nm7_pbEndOfRoundPhase)
  def pbEndOfRoundPhase
    pbPriority(true).each do |b|
      next if b.fainted? || !b.instance_variable_get(:@kifer_nm7_salt) || !b.takesIndirectDamage?
      oldHP = b.hp
      div = (b.pbHasType?(:WATER) || b.pbHasType?(:STEEL)) ? 4 : 8
      b.pbReduceHP(b.totalhp / div)
      pbDisplay(_INTL("{1} is hurt by Salt Cure!", b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    kifer_nm7_pbEndOfRoundPhase
  end
end

KIFER::AIAs.add(KIFER::NewMoveFx7::AI_AS)   # AI scoring and Enrage wrap (069)

KIFER::Moves.coded(:BURNINGBULWARK, function_code: "KERD72")
KIFER::Moves.coded(:OBSTRUCT, function_code: "KERD73")
KIFER::Moves.coded(:DIRECLAW, function_code: "KERD74")
KIFER::Moves.coded(:TRANSMUTE, function_code: "KERD75")
KIFER::Moves.coded(:CHILLYRECEPTION, function_code: "KERD76")
KIFER::Moves.coded(:GRAVAPPLE, function_code: "KERD77")
KIFER::Moves.coded(:CLANGOROUSSOUL, function_code: "KERD78")
KIFER::Moves.coded(:BEHEMOTHBASH, function_code: "KERD79")
KIFER::Moves.coded(:TAKEHEART, function_code: "KERD80")
KIFER::Moves.coded(:RAGEFIST, function_code: "KERD81")
KIFER::Moves.coded(:BITTERMALICE, function_code: "KERD82")
KIFER::Moves.coded(:SALTCURE, function_code: "KERD83")
KIFER::Moves.coded(:SANDSEARSTORM, function_code: "KERD84")
KIFER::Moves.coded(:SAPPYSEED, :BRAMBLEBLAST, function_code: "KERD85")
KIFER::Moves.coded(:CEASELESSEDGE, function_code: "KERD86")
KIFER::Moves.coded(:SPICYEXTRACT, function_code: "KERD87")
KIFER::Moves.coded(:BOLTBEAK, :FISHIOUSREND, function_code: "KERD88")
KIFER::Moves.coded(:GLITZYGLOW, function_code: "KERD89")
KIFER::Moves.coded(:KILOBITE, function_code: "KERD90")
KIFER::Moves.coded(:AXEKICK, function_code: "KERD91")
KIFER::Moves.coded(:FICKLEBEAM, function_code: "KERD92")
KIFER::Moves.coded(:FILLETAWAY, function_code: "KERD93")
KIFER::Moves.coded(:VIRALSTRIKE, function_code: "KERD94")
KIFER::Moves.coded(:DRAKEMISSILE, function_code: "000", target: :AllNearFoes)   # ER text: hits both foes
KIFER::Moves.coded(:LIGHTNINGSTRIKE, function_code: "01F", chance: 20)   # ER text: 20% Speed +1 (the ROM chance is 0)
KIFER::Moves.coded(:WILDSWING, function_code: "0EC")
KIFER::Moves.coded(:COMEUPPANCE, function_code: "073", power: 1)   # PIF's fixed-damage moves have power 1
KIFER::Moves.coded(:GIANTGALE, function_code: "03E")
KIFER::Moves.coded(:RIDERKICK, function_code: "163")
KIFER::Moves.coded(:TACHYONCUTTER, function_code: "0BD")
KIFER::Moves.coded(:FLOWERTRICK, function_code: "0A0")
KIFER::Moves.coded(:LUNARBLESSING, function_code: "KERD43")
KIFER::Moves.coded(:SQUEAKYHAMMER, function_code: "KERD59")
KIFER::NewMoves.register   # in the game now (064)
