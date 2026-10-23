#===============================================================================
# KIF: Elite Redux – effects for Elite Redux moves PIF doesn't have, batch 5
#   Shed Tail       – costs 1/2 max HP: the user switches out and the Pokemon
#                     coming in gets a substitute of 1/4 of the user's max HP
#   Double Shock    – Electric users only; hits twice, then the user loses its
#                     Electric type until it switches out (Burn Up's way)
#   Toxic Needles   – hits 2-5 times; 10% poison per hit
#   Jungle Healing  – the user and its allies heal 1/4 max HP and their status
#   Diamond Blade   – 10% bleeding and, rolled apart, 10% Stealth Rock on the
#                     target's side (Cody: both)
#   Last Respects   – +50 power per fainted Pokemon in the user's party (Cody)
#   Jagged Punch    – 10% Stealth Rock on the target's side
#   Barb Barrage    – 30% poison; x1.5 power against a target with a status
#   Infernal Parade – 30% burn; x1.5 power against a target with a status
#   No Retreat      – all the user's stats +1; it can't switch out after
#   Requiem, Shadow Fangs – 10% Ghost-type Curse on the target
#   Shelter         – Defense +2 for the user and its partner
#   Alluring Voice  – confuses a target with any raised stat (Cody: whenever
#                     it was raised)
#   Cheap Shot      – PIF's Shadow Force class (vanishes, then hits through
#                     Protect)
#   Battle AI (both): each is scored as the PIF move it works like.
#===============================================================================
module KIFER
  module NewMoveFx5
    AI_AS = { "KERD40" => "0ED", "KERD41" => "162", "KERD42" => "0C0", "KERD43" => "0D5",
              "KERD44" => "000", "KERD45" => "000", "KERD46" => "000", "KERD47" => "005",
              "KERD48" => "00A", "KERD49" => "02D", "KERD50" => "000", "KERD51" => "02F",
              "KERD52" => "013" }

    module_function

    def curse(battle, target)
      return if target.fainted? || target.effects[PBEffects::Curse]
      target.effects[PBEffects::Curse] = true
      battle.pbDisplay(_INTL("{1} was cursed!", target.pbThis))
    end
  end
end

class PokeBattle_Move_KERD40 < PokeBattle_Move   # Shed Tail
  def pbMoveFailed?(user, targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @kifer_cost = (user.totalhp / 2.0).ceil
    if user.hp <= @kifer_cost
      @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbReduceHP(@kifer_cost, false, false)
    user.pbItemHPHealCheck
    @battle.pbDisplay(_INTL("{1} shed its tail to create a decoy!", user.pbThis))
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    sub = [user.totalhp / 4, 1].max
    KIFER::Fx.switch_out(@battle, user, switchedBattlers) do
      user.effects[PBEffects::Substitute] = sub
      @battle.pbDisplay(_INTL("{1} is behind the decoy!", user.pbThis))
    end
  end
end

class PokeBattle_Move_KERD41 < PokeBattle_Move   # Double Shock
  def multiHitMove?; return true; end
  def pbNumHits(user, targets); return 2; end

  def pbMoveFailed?(user, targets)
    return false if user.pbHasType?(:ELECTRIC)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || user.instance_variable_get(:@kifer_nm5_shocked)
    user.instance_variable_set(:@kifer_nm5_shocked, true)
    @battle.pbDisplay(_INTL("{1} used up all its electricity!", user.pbThis))
  end
end

class PokeBattle_Move_KERD42 < PokeBattle_Move_0C0   # Toxic Needles
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbPoison(user) if target.pbCanPoison?(user, false, self)
  end
end

class PokeBattle_Move_KERD43 < PokeBattle_Move   # Jungle Healing
  def healingMove?; return true; end

  def kifer_needs?(b)
    return b.canHeal? || b.status != :NONE
  end

  def pbMoveFailed?(user, targets)
    return false if KIFER::Fx.with_allies(user).any? { |b| kifer_needs?(b) }
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    KIFER::Fx.with_allies(user).each do |b|
      if b.canHeal?
        b.pbRecoverHP((b.totalhp / 4.0).round)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", b.pbThis))
      end
      b.pbCureStatus if b.status != :NONE
    end
  end
end

class PokeBattle_Move_KERD44 < PokeBattle_Move   # Diamond Blade
  def pbAdditionalEffect(user, target)   # the move's own 10%: bleeding
    return if target.damageState.substitute || !KIFER.feature_on?(:bleeding)
    target.pbBleed(user) if target.pbCanBleed?(user, false, self)
  end

  def pbEffectAgainstTarget(user, target)   # its other 10%: Stealth Rock
    return if target.damageState.unaffected || target.damageState.substitute
    return if @battle.pbRandom(100) >= 10
    KIFER::Fx.stealth_rock(@battle, target.pbOwnSide, user)
  end
end

class PokeBattle_Move_KERD45 < PokeBattle_Move   # Last Respects
  def pbBaseDamage(baseDmg, user, target)
    fainted = @battle.pbParty(user.index).count { |p| p && !p.egg? && p.fainted? }
    return baseDmg + 50 * fainted
  end
end

class PokeBattle_Move_KERD46 < PokeBattle_Move   # Jagged Punch
  def pbAdditionalEffect(user, target)
    return if target.fainted?
    KIFER::Fx.stealth_rock(@battle, target.pbOwnSide, user)
  end
end

class PokeBattle_Move_KERD47 < PokeBattle_Move_005   # Barb Barrage
  def pbBaseDamage(baseDmg, user, target)
    return target.status != :NONE ? (baseDmg * 1.5).round : baseDmg
  end
end

class PokeBattle_Move_KERD48 < PokeBattle_Move_00A   # Infernal Parade
  def pbBaseDamage(baseDmg, user, target)
    return target.status != :NONE ? (baseDmg * 1.5).round : baseDmg
  end
end

class PokeBattle_Move_KERD49 < PokeBattle_MultiStatUpMove   # No Retreat
  def initialize(battle, move)
    super
    @statUp = [:ATTACK, 1, :DEFENSE, 1, :SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1]
  end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::MeanLook] == user.index
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    super
    return if user.effects[PBEffects::MeanLook] >= 0
    user.effects[PBEffects::MeanLook] = user.index   # cleared when it leaves the field
    @battle.pbDisplay(_INTL("{1} can no longer escape because it used No Retreat!", user.pbThis))
  end
end

class PokeBattle_Move_KERD50 < PokeBattle_Move   # Requiem, Shadow Fangs
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    KIFER::NewMoveFx5.curse(@battle, target)
  end
end

class PokeBattle_Move_KERD51 < PokeBattle_Move   # Shelter
  def pbMoveFailed?(user, targets)
    return false if KIFER::Fx.with_allies(user).any? { |b| b.pbCanRaiseStatStage?(:DEFENSE, user, self) }
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    KIFER::Fx.with_allies(user).each do |b|
      b.pbRaiseStatStage(:DEFENSE, 2, user) if b.pbCanRaiseStatStage?(:DEFENSE, user, self)
    end
  end
end

class PokeBattle_Move_KERD52 < PokeBattle_Move   # Alluring Voice
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute || !target.stages.values.any? { |v| v > 0 }
    target.pbConfuse if target.pbCanConfuse?(user, false, self)
  end
end

# Double Shock: no Electric type until it leaves the field
class PokeBattle_Battler
  alias kifer_nm5_pbTypes pbTypes unless method_defined?(:kifer_nm5_pbTypes)
  def pbTypes(withType3 = false)
    ret = kifer_nm5_pbTypes(withType3)
    return ret if !@kifer_nm5_shocked
    return ret - [:ELECTRIC]
  end

  alias kifer_nm5_pbInitEffects pbInitEffects unless method_defined?(:kifer_nm5_pbInitEffects)
  def pbInitEffects(batonPass)
    kifer_nm5_pbInitEffects(batonPass)
    @kifer_nm5_shocked = false
  end
end

KIFER::AIAs.add(KIFER::NewMoveFx5::AI_AS)   # AI scoring and Enrage wrap (069)

KIFER::Moves.coded(:SHEDTAIL, function_code: "KERD40")
KIFER::Moves.coded(:DOUBLESHOCK, function_code: "KERD41")
KIFER::Moves.coded(:TOXICNEEDLES, function_code: "KERD42")
KIFER::Moves.coded(:JUNGLEHEALING, function_code: "KERD43")
KIFER::Moves.coded(:DIAMONDBLADE, function_code: "KERD44")
KIFER::Moves.coded(:LASTRESPECTS, function_code: "KERD45")
KIFER::Moves.coded(:JAGGEDPUNCH, function_code: "KERD46")
KIFER::Moves.coded(:BARBBARRAGE, function_code: "KERD47")
KIFER::Moves.coded(:INFERNALPARADE, function_code: "KERD48")
KIFER::Moves.coded(:NORETREAT, function_code: "KERD49")
KIFER::Moves.coded(:REQUIEM, :SHADOWFANGS, function_code: "KERD50")
KIFER::Moves.coded(:SHELTER, function_code: "KERD51")
KIFER::Moves.coded(:ALLURINGVOICE, function_code: "KERD52")
KIFER::Moves.coded(:CHEAPSHOT, function_code: "0CD")
KIFER::NewMoves.register   # in the game now (064)
