#===============================================================================
# KIF: Elite Redux – effects for Elite Redux moves PIF doesn't have, batch 6
#   Mortal Spin     – Rapid Spin (its own side's hazards and KIF-ER's thorns)
#                     and poisons the foes it hits
#   Super Hot Flame – x1.5 in rain instead of halved (Cody)
#   Ghastly Echo    – U-turn; the Pokemon coming in does x1.5 damage that turn
#                     and its next (Cody)
#   Drain Brain     – Strength Sap on Sp. Atk
#   Fertile Fangs   – 10% Leech Seed
#   Jagged Horns    – 10% flinch and, rolled apart, 10% bleeding
#   Cutsie Slap     – 10% infatuation
#   Rip and Tear    – the target's Speed -1; 50% bleeding (no repeat: 068)
#   Snipe Shot      – can't be redirected (Follow Me, Lightning Rod...)
#   Tidy Up         – clears hazards, thorns and caltrops on both sides and
#                     every substitute (Cody: both sides); Attack and Speed +1
#   Web Shot        – sets Sticky Web on the target's side
#   Freezy Frost    – resets every Pokemon's stat changes (Haze)
#   Baddy Bad       – sets Reflect on the user's side
#   Psyblade        – x1.5 on Electric Terrain
#   Spin Out        – the user's Speed -2
#   Stuff Cheeks    – fails without a berry: eats it, then Defense +2
#   Toxic Plunge    – PIF's Dive class; its chance poisons
#   Wildbolt Storm  – starts rain; Bleakwind Storm – starts Tailwind
#   Bonk            – 50% drowsiness (Yawn)
#   Zippy Zap       – PIF's always-critical class; Fairy Spheres – hits 2-5 times
#   Battle AI (both): each is scored as the PIF move it works like.
#===============================================================================
module KIFER
  module NewMoveFx6
    AI_AS = { "KERD53" => "110", "KERD54" => "000", "KERD55" => "0EE", "KERD56" => "160",
              "KERD57" => "000", "KERD58" => "00F", "KERD59" => "000", "KERD60" => "044",
              "KERD61" => "000", "KERD62" => "110", "KERD63" => "000", "KERD64" => "051",
              "KERD65" => "000", "KERD66" => "000", "KERD67" => "000", "KERD68" => "02F",
              "KERD69" => "000", "KERD70" => "000", "KERD71" => "004" }

    module_function

    # Ghastly Echo: the battler it brought in, this turn and the next
    def echo?(battle, battler)
      t = battler.instance_variable_get(:@kifer_nm6_echo)
      return t && (battle.turnCount - t).between?(0, 1)
    end

    def clear_side(battle, side, user)
      e = side.effects
      cleared = e[PBEffects::StealthRock] || e[PBEffects::Spikes] > 0 ||
                e[PBEffects::ToxicSpikes] > 0 || e[PBEffects::StickyWeb]
      e[PBEffects::StealthRock] = false
      e[PBEffects::Spikes] = 0
      e[PBEffects::ToxicSpikes] = 0
      e[PBEffects::StickyWeb] = false
      KIFER::MoveFxField.clear_thorns(battle, side, user)   # and caltrops (070)
      return cleared
    end
  end
end

class PokeBattle_Move_KERD53 < PokeBattle_Move_110   # Mortal Spin
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbPoison(user) if target.pbCanPoison?(user, false, self)
  end
end

class PokeBattle_Move_KERD54 < PokeBattle_Move   # Super Hot Flame
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    super
    multipliers[:final_damage_multiplier] *= 3 if type == :FIRE && @battle.pbWeather == :Rain   # /2 -> x1.5
  end
end

class PokeBattle_Move_KERD55 < PokeBattle_Move_0EE   # Ghastly Echo
  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    switched = switchedBattlers.include?(user.index)
    super
    return if switched || !switchedBattlers.include?(user.index)
    user.instance_variable_set(:@kifer_nm6_echo, @battle.turnCount)   # the battler now holds the Pokemon that came in
    @battle.pbDisplay(_INTL("{1} is spurred on by the echo!", user.pbThis))
  end
end

class PokeBattle_Move_KERD56 < PokeBattle_Move   # Drain Brain
  def healingMove?; return true; end

  def pbFailsAgainstTarget?(user, target)
    return false if !target.statStageAtMin?(:SPECIAL_ATTACK)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectAgainstTarget(user, target)
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    st = target.stages[:SPECIAL_ATTACK] + 6
    healAmt = (target.spatk.to_f * stageMul[st] / stageDiv[st]).floor
    target.pbLowerStatStage(:SPECIAL_ATTACK, 1, user) if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user, self)
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt * 1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
    end
  end
end

class PokeBattle_Move_KERD57 < PokeBattle_Move   # Fertile Fangs
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    KIFER::Fx.leech_seed(@battle, user, target)
  end
end

class PokeBattle_Move_KERD58 < PokeBattle_Move   # Jagged Horns
  def flinchingMove?; return true; end

  def pbAdditionalEffect(user, target)   # the move's own 10%: flinch
    target.pbFlinch(user) unless target.damageState.substitute
  end

  def pbEffectAgainstTarget(user, target)   # its other 10%: bleeding
    return if target.damageState.unaffected || target.damageState.substitute || !KIFER.feature_on?(:bleeding)
    return if @battle.pbRandom(100) >= 10
    target.pbBleed(user) if target.pbCanBleed?(user, false, self)
  end
end

class PokeBattle_Move_KERD59 < PokeBattle_Move   # Cutsie Slap
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbAttract(user) if target.pbCanAttract?(user, false)
  end
end

class PokeBattle_Move_KERD60 < PokeBattle_Move   # Rip and Tear
  def pbEffectAgainstTarget(user, target)   # always
    return if target.damageState.unaffected || target.damageState.substitute
    target.pbLowerStatStage(:SPEED, 1, user) if target.pbCanLowerStatStage?(:SPEED, user, self)
  end

  def pbAdditionalEffect(user, target)   # 50%
    return if target.damageState.substitute || !KIFER.feature_on?(:bleeding)
    target.pbBleed(user) if target.pbCanBleed?(user, false, self)
  end
end

class PokeBattle_Move_KERD61 < PokeBattle_Move   # Snipe Shot
  def cannotRedirect?; return true; end
end

class PokeBattle_Move_KERD62 < PokeBattle_Move   # Tidy Up
  def pbMoveFailed?(user, targets)
    return false if [:ATTACK, :SPEED].any? { |s| user.pbCanRaiseStatStage?(s, user, self) }
    @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis))
    return true
  end

  def pbEffectGeneral(user)
    cleared = false
    [user.pbOwnSide, user.pbOpposingSide].each { |s| cleared = true if KIFER::NewMoveFx6.clear_side(@battle, s, user) }
    @battle.eachBattler do |b|
      next if b.effects[PBEffects::Substitute] <= 0
      b.effects[PBEffects::Substitute] = 0
      cleared = true
    end
    @battle.pbDisplay(_INTL("Tidying up complete!")) if cleared
    anim = true
    [:ATTACK, :SPEED].each do |s|
      next if !user.pbCanRaiseStatStage?(s, user, self)
      anim = false if user.pbRaiseStatStage(s, 1, user, anim)
    end
  end
end

class PokeBattle_Move_KERD63 < PokeBattle_Move   # Web Shot
  def pbAdditionalEffect(user, target)
    side = target.pbOwnSide
    return if side.effects[PBEffects::StickyWeb]
    side.effects[PBEffects::StickyWeb] = true
    @battle.pbDisplay(_INTL("A sticky web spreads out on the ground around {1}!", user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_KERD64 < PokeBattle_Move   # Freezy Frost
  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    @battle.eachBattler { |b| b.pbResetStatStages }
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
  end
end

class PokeBattle_Move_KERD65 < PokeBattle_Move   # Baddy Bad
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    KIFER::Fx.screen(@battle, user, PBEffects::Reflect, _INTL("Reflect"))
  end
end

class PokeBattle_Move_KERD66 < PokeBattle_Move   # Psyblade
  def pbBaseDamage(baseDmg, user, target)
    return @battle.field.terrain == :Electric ? (baseDmg * 1.5).round : baseDmg
  end
end

class PokeBattle_Move_KERD67 < PokeBattle_Move   # Spin Out
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    user.pbLowerStatStage(:SPEED, 2, user) if user.pbCanLowerStatStage?(:SPEED, user, self)
  end
end

class PokeBattle_Move_KERD68 < PokeBattle_Move   # Stuff Cheeks
  def pbMoveFailed?(user, targets)
    return false if user.item && user.item.is_berry?
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    KIFER::Fx.eat_berry(@battle, user)
    user.pbRaiseStatStage(:DEFENSE, 2, user) if user.pbCanRaiseStatStage?(:DEFENSE, user, self)
  end
end

class PokeBattle_Move_KERD69 < PokeBattle_Move   # Wildbolt Storm
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    return if [:Rain, :HeavyRain, :HarshSun, :StrongWinds].include?(@battle.field.weather)
    @battle.pbStartWeather(user, :Rain, true, false)
  end
end

class PokeBattle_Move_KERD70 < PokeBattle_Move   # Bleakwind Storm
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected || user.pbOwnSide.effects[PBEffects::Tailwind] > 0
    user.pbOwnSide.effects[PBEffects::Tailwind] = 4
    @battle.pbDisplay(_INTL("The Tailwind blew from behind {1}!", user.pbTeam(true)))
  end
end

class PokeBattle_Move_KERD71 < PokeBattle_Move   # Bonk
  def pbAdditionalEffect(user, target)
    return if target.fainted? || target.damageState.substitute || target.effects[PBEffects::Yawn] > 0
    return if !target.pbCanSleep?(user, false, self)
    target.effects[PBEffects::Yawn] = 2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!", user.pbThis, target.pbThis(true)))
  end
end

# Toxic Plunge: PIF's Dive (its function code keeps it underwater), and its
# chance poisons
class PokeBattle_Move_0CB
  alias kifer_nm6_pbAdditionalEffect pbAdditionalEffect unless method_defined?(:kifer_nm6_pbAdditionalEffect)
  def pbAdditionalEffect(user, target)
    return kifer_nm6_pbAdditionalEffect(user, target) if @id != :TOXICPLUNGE
    return if target.damageState.substitute
    target.pbPoison(user) if target.pbCanPoison?(user, false, self)
  end
end

# Ghastly Echo: x1.5 for the Pokemon it brought in
class PokeBattle_Move
  alias kifer_nm6_pbCalcDamageMultipliers pbCalcDamageMultipliers unless method_defined?(:kifer_nm6_pbCalcDamageMultipliers)
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    kifer_nm6_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    multipliers[:final_damage_multiplier] *= 1.5 if KIFER::NewMoveFx6.echo?(@battle, user)
  end
end

KIFER::AIAs.add(KIFER::NewMoveFx6::AI_AS)   # AI scoring and Enrage wrap (069)

KIFER::Moves.coded(:MORTALSPIN, function_code: "KERD53")
KIFER::Moves.coded(:SUPERHOTFLAME, function_code: "KERD54")
KIFER::Moves.coded(:GHASTLYECHO, function_code: "KERD55")
KIFER::Moves.coded(:DRAINBRAIN, function_code: "KERD56")
KIFER::Moves.coded(:FERTILEFANGS, function_code: "KERD57")
KIFER::Moves.coded(:JAGGEDHORNS, function_code: "KERD58")
KIFER::Moves.coded(:CUTSIESLAP, function_code: "KERD59")
KIFER::Moves.coded(:RIPANDTEAR, function_code: "KERD60")
KIFER::Moves.coded(:SNIPESHOT, function_code: "KERD61")
KIFER::Moves.coded(:TIDYUP, function_code: "KERD62")
KIFER::Moves.coded(:WEBSHOT, function_code: "KERD63")
KIFER::Moves.coded(:FREEZYFROST, function_code: "KERD64")
KIFER::Moves.coded(:BADDYBAD, function_code: "KERD65")
KIFER::Moves.coded(:PSYBLADE, function_code: "KERD66")
KIFER::Moves.coded(:SPINOUT, function_code: "KERD67")
KIFER::Moves.coded(:STUFFCHEEKS, function_code: "KERD68")
KIFER::Moves.coded(:TOXICPLUNGE, function_code: "0CB")
KIFER::Moves.coded(:WILDBOLTSTORM, function_code: "KERD69")
KIFER::Moves.coded(:BLEAKWINDSTORM, function_code: "KERD70")
KIFER::Moves.coded(:BONK, function_code: "KERD71")
KIFER::Moves.coded(:ZIPPYZAP, function_code: "0A0")
KIFER::Moves.coded(:FAIRYSPHERES, function_code: "0C0")
KIFER::NewMoves.register   # in the game now (064)
