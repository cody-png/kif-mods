#===============================================================================
# KIF: Elite Redux – effects for Elite Redux moves PIF doesn't have, batch 3
#   Dragon Cheer    – the user and its allies: critical-hit ratio +1, +2 for
#                     Dragon types (Cody: the user too); fails if none can
#   Life Dew        – the user and its allies heal 1/4 of their max HP (Cody: HP
#                     only, no status cure)
#   Expanding Force – on Psychic Terrain (grounded user): x1.5 power and hits
#                     all foes
#   Creeping Thorns – sets KIF-ER's creeping thorns (061) on the foes' side
#   Scale Shot      – hits 2-5 times, then the user's Speed +1, Defense -1
#   Wyrm Wind       – hits 2-5 times, then the user's Speed +1, Sp. Def -1
#   Steel Beam      – the user loses 1/2 of its max HP, hit or miss (Cody)
#   Eerie Spell     – the target's last move loses 6 PP; never misses in fog
#   Rapid River     – hits twice; its chance drenches (031)
#   Eerie Fog       – sets fog (030) for 8 turns, 12 with a Smoke Ball
#   Caltrops        – the next grounded foe to come in starts bleeding (031),
#                     then the caltrops are gone (Cody); Rapid Spin and Defog
#                     clear them with the thorns
#   Battle AI (both): each is scored as the PIF move it works like.
#===============================================================================
module KIFER
  module NewMoveFx3
    AI_AS = { "KERD18" => "023", "KERD19" => "0D5", "KERD20" => "000", "KERD21" => "103",
              "KERD22" => "0C0", "KERD23" => "0C0", "KERD24" => "0FC", "KERD25" => "000",
              "KERD26" => "0BD", "KERD27" => "000", "KERD28" => "104" }

    module_function

    def with_allies(user)
      ret = [user]
      user.eachAlly { |b| ret << b }
      return ret
    end

    def caltrops?(side)
      return side.instance_variable_get(:@kifer_nm3_caltrops) ? true : false
    end

    # a Pokemon comes in on a side with caltrops
    def caltrops_entry(battle, battler)
      return if !caltrops?(battler.pbOwnSide) || battler.airborne?
      battler.pbOwnSide.instance_variable_set(:@kifer_nm3_caltrops, false)
      battle.pbDisplay(_INTL("{1} stepped on the caltrops!", battler.pbThis))
      battler.pbBleed if KIFER.feature_on?(:bleeding) && battler.pbCanBleed?(nil, false)
    end
  end
end

class PokeBattle_Move_KERD18 < PokeBattle_Move   # Dragon Cheer
  def pbMoveFailed?(user, targets)
    return false if KIFER::NewMoveFx3.with_allies(user).any? { |b| b.effects[PBEffects::FocusEnergy] == 0 }
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    KIFER::NewMoveFx3.with_allies(user).each do |b|
      next if b.effects[PBEffects::FocusEnergy] > 0
      b.effects[PBEffects::FocusEnergy] = b.pbHasType?(:DRAGON) ? 2 : 1
      @battle.pbDisplay(_INTL("{1} is getting pumped!", b.pbThis))
    end
  end
end

class PokeBattle_Move_KERD19 < PokeBattle_Move   # Life Dew
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    return false if KIFER::NewMoveFx3.with_allies(user).any? { |b| b.canHeal? }
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    KIFER::NewMoveFx3.with_allies(user).each do |b|
      next if !b.canHeal?
      b.pbRecoverHP((b.totalhp / 4.0).round)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", b.pbThis))
    end
  end
end

class PokeBattle_Move_KERD20 < PokeBattle_Move   # Expanding Force
  def kifer_expanded?(user)
    return @battle.field.terrain == :Psychic && !user.airborne?
  end

  def pbTarget(user)
    return GameData::Target.get(:AllNearFoes) if kifer_expanded?(user)
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    return kifer_expanded?(user) ? (baseDmg * 1.5).round : baseDmg
  end
end

class PokeBattle_Move_KERD21 < PokeBattle_Move   # Creeping Thorns
  def pbMoveFailed?(user, targets)
    return false if !KIFER::MoveFxField.thorns?(user.pbOpposingSide)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.instance_variable_set(:@kifer_mx_thorns, true)
    @battle.pbDisplay(_INTL("Creeping thorns surround {1}!", user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_KERD22 < PokeBattle_Move_0C0   # Scale Shot
  def kifer_stats; return [:SPEED, :DEFENSE]; end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    up, down = kifer_stats
    user.pbRaiseStatStage(up, 1, user) if user.pbCanRaiseStatStage?(up, user, self)
    user.pbLowerStatStage(down, 1, user) if user.pbCanLowerStatStage?(down, user, self)
  end
end

class PokeBattle_Move_KERD23 < PokeBattle_Move_KERD22   # Wyrm Wind
  def kifer_stats; return [:SPEED, :SPECIAL_DEFENSE]; end
end

class PokeBattle_Move_KERD24 < PokeBattle_Move   # Steel Beam
  def pbSelfKO(user)
    return if !user.takesIndirectDamage?
    user.pbReduceHP((user.totalhp / 2.0).round, false)
    user.pbItemHPHealCheck
  end

  def pbCrashDamage(user)   # PIF's path when it misses every target
    pbSelfKO(user)
  end
end

class PokeBattle_Move_KERD25 < PokeBattle_Move   # Eerie Spell
  def pbBaseAccuracy(user, target)
    return 0 if KIFER::Fog.active?(@battle)
    return super
  end

  def pbEffectAgainstTarget(user, target)   # not a chance effect (the ROM's chance is 0)
    return if target.fainted? || target.damageState.unaffected || !target.lastRegularMoveUsed
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed || m.pp == 0
      cut = [6, m.pp].min
      target.pbSetPP(m, m.pp - cut)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!", target.pbThis(true), m.name, cut))
      break
    end
  end
end

class PokeBattle_Move_KERD26 < PokeBattle_Move_0BD   # Rapid River
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    KIFER::Drench.on_hit(user, target, nil, 100)
  end
end

class PokeBattle_Move_KERD27 < PokeBattle_WeatherMove   # Eerie Fog
  def initialize(battle, move)
    super
    @weatherType = :Fog
  end

  def pbMoveFailed?(user, targets)
    if !KIFER.feature_on?(:fog)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end
end

class PokeBattle_Move_KERD28 < PokeBattle_Move   # Caltrops
  def pbMoveFailed?(user, targets)
    return false if !KIFER::NewMoveFx3.caltrops?(user.pbOpposingSide)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.instance_variable_set(:@kifer_nm3_caltrops, true)
    @battle.pbDisplay(_INTL("Caltrops are scattered around {1}!", user.pbOpposingTeam(true)))
  end
end

# Rapid Spin and Defog clear caltrops wherever they clear the thorns
module KIFER
  module MoveFxField
    class << self
      alias kifer_nm3_clear_thorns clear_thorns unless method_defined?(:kifer_nm3_clear_thorns)
      def clear_thorns(battle, side, user)
        kifer_nm3_clear_thorns(battle, side, user)
        return if !KIFER::NewMoveFx3.caltrops?(side)
        side.instance_variable_set(:@kifer_nm3_caltrops, false)
        battle.pbDisplay(_INTL("{1} blew away the caltrops!", user.pbThis))
      end
    end
  end
end

class PokeBattle_Battle
  alias kifer_nm3_pbOnActiveOne pbOnActiveOne unless method_defined?(:kifer_nm3_pbOnActiveOne)
  def pbOnActiveOne(battler)
    ret = kifer_nm3_pbOnActiveOne(battler)
    KIFER::NewMoveFx3.caltrops_entry(self, battler) if ret && !battler.fainted?
    return ret
  end
end

class PokeBattle_AI
  alias kifer_nmf3_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode unless method_defined?(:kifer_nmf3_pbGetMoveScoreFunctionCode)
  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    f = move && move.function
    as = KIFER::NewMoveFx3::AI_AS[f]
    return kifer_nmf3_pbGetMoveScoreFunctionCode(score, move, user, target, skill) if !as
    move.instance_variable_set(:@function, as)   # scored as the PIF move it works like
    begin
      return kifer_nmf3_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    ensure
      move.instance_variable_set(:@function, f)
    end
  end
end

KIFER::NewMoveFx3::AI_AS.each_key do |c|
  k = Object.const_get("PokeBattle_Move_#{c}")
  KIFER::TerrainEnrage.wrap_move_class(k) if defined?(KIFER::TerrainEnrage) && KIFER::TerrainEnrage.respond_to?(:wrap_move_class)
end
KIFER::Statuses.hook_heal_moves if defined?(KIFER::Statuses) && KIFER::Statuses.respond_to?(:hook_heal_moves)

KIFER::Moves.coded(:DRAGONCHEER, function_code: "KERD18")
KIFER::Moves.coded(:LIFEDEW, function_code: "KERD19")
KIFER::Moves.coded(:EXPANDINGFORCE, function_code: "KERD20")
KIFER::Moves.coded(:CREEPINGTHORNS, function_code: "KERD21")
KIFER::Moves.coded(:SCALESHOT, function_code: "KERD22")
KIFER::Moves.coded(:WYRMWIND, function_code: "KERD23")
KIFER::Moves.coded(:STEELBEAM, function_code: "KERD24")
KIFER::Moves.coded(:EERIESPELL, function_code: "KERD25")
KIFER::Moves.coded(:RAPIDRIVER, function_code: "KERD26", chance: 10)   # ER text: 10% drench (the ROM data says 0)
KIFER::Moves.coded(:EERIEFOG, function_code: "KERD27", target: :BothSides, flags: "")
KIFER::Moves.coded(:CALTROPS, function_code: "KERD28")
KIFER::NewMoves.register   # in the game now (064)
