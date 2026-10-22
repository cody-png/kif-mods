#===============================================================================
# KIF: Elite Redux – effects for Elite Redux moves PIF doesn't have, batch 4
#   Corrosive Gas   – hits everyone next to the user; each one hit loses its
#                     item for the battle (Knock Off's way; Cody: the ally too)
#   Scorched Earth  – fully a Ground move (type, STAB, immunities) against a
#                     target Ground hits harder than Fire (Cody); airborne
#                     targets and ties get Fire; 10% burn
#   Electro Shot    – two turns, Sp. Atk +1 on the charging turn; in rain it
#                     fires at once (Solar Beam's way)
#   Safe Passage    – the user switches out; the Pokemon coming in takes 35%
#                     less damage this turn
#   Misty Explosion – the user faints (Explosion); x1.5 on Misty Terrain
#                     (grounded user)
#   Berry Smash     – fails without a held berry (Cody); after hitting, the
#                     user eats its berry and gets the effect
#   Triple Dive     – hits 3 times
#   Smite           – 20% paralysis; grounds the target (Smack Down)
#   Jaw Lock        – neither the user nor the target can switch out while
#                     both stay in (Mean Look both ways; Ghosts still can)
#   Excalibur       – double damage against Dragon types
#   Bad Egg         – PIF's Toxic class (badly poisons on hit)
#   Decorate        – at a foe: damages. At an ally: Attack and Sp. Atk +2 and
#                     critical-hit ratio +2, no damage (Pollen Puff's way)
#   Thundercall     – after an Electric move, a 24 power Smite (025's follow-up)
#   Current Crash   – Reckless + Thundercall (028's parts)
#   Battle AI (both): each is scored as the PIF move it works like.
#===============================================================================
module KIFER
  module NewMoveFx4
    AI_AS = { "KERD29" => "0F0", "KERD30" => "00A", "KERD31" => "0C4", "KERD32" => "000",
              "KERD33" => "0E0", "KERD34" => "000", "KERD35" => "000", "KERD36" => "11C",
              "KERD37" => "0EF", "KERD38" => "000", "KERD39" => "000" }

    module_function

    # Scorched Earth's type against this target
    def scorched_type(target)
      t = target.pbTypes(true)
      fire = Effectiveness.calculate(:FIRE, t[0], t[1], t[2])
      ground = target.airborne? ? 0 : Effectiveness.calculate(:GROUND, t[0], t[1], t[2])
      return ground > fire ? :GROUND : :FIRE
    end

    # Safe Passage: the battler that came in this turn at this index
    def safe?(battle, battler)
      s = battle.instance_variable_get(:@kifer_nm4_safe)
      return s && s[0] == battler.index && s[1] == battle.turnCount
    end
  end
end

class PokeBattle_Move_KERD29 < PokeBattle_Move   # Corrosive Gas
  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1}'s {2} melted away!", target.pbThis, itemName))
  end
end

class PokeBattle_Move_KERD30 < PokeBattle_Move_00A   # Scorched Earth
  def pbCalcType(user)
    ret = super
    return ret if ret != :FIRE
    ch = @battle.choices[user.index]
    idx = ch.is_a?(Array) ? ch[3] : nil
    t = (idx.is_a?(Integer) && idx >= 0) ? @battle.battlers[idx] : nil
    t = nil if t && (t.fainted? || !t.opposes?(user))
    t ||= user.pbDirectOpposing(true)
    return ret if !t || t.fainted?
    return KIFER::NewMoveFx4.scorched_type(t)
  end
end

class PokeBattle_Move_KERD31 < PokeBattle_TwoTurnMove   # Electro Shot
  def pbIsChargingTurn?(user)
    ret = super
    if !user.effects[PBEffects::TwoTurnAttack] && [:Rain, :HeavyRain].include?(@battle.pbWeather)
      @powerHerb = false
      @chargingTurn = true
      @damagingTurn = true
      return false
    end
    return ret
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} absorbed electricity!", user.pbThis))
  end

  def pbChargingTurnEffect(user, target)
    user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
  end
end

class PokeBattle_Move_KERD32 < PokeBattle_Move   # Safe Passage
  def pbMoveFailed?(user, targets)
    return false if @battle.pbCanChooseNonActive?(user.index)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    return if user.fainted? || !@battle.pbCanChooseNonActive?(user.index)
    @battle.pbDisplay(_INTL("{1} went back to {2}!", user.pbThis, @battle.pbGetOwnerName(user.index)))
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    switchedBattlers.push(user.index)
    @battle.instance_variable_set(:@kifer_nm4_safe, [user.index, @battle.turnCount])
    @battle.pbDisplay(_INTL("{1} is guarded on its way in!", user.pbThis))
    user.pbEffectsOnSwitchIn(true)
  end
end

class PokeBattle_Move_KERD33 < PokeBattle_Move_0E0   # Misty Explosion
  def pbBaseDamage(baseDmg, user, target)
    return (baseDmg * 1.5).round if @battle.field.terrain == :Misty && !user.airborne?
    return baseDmg
  end
end

class PokeBattle_Move_KERD34 < PokeBattle_Move   # Berry Smash
  def pbMoveFailed?(user, targets)
    return false if user.item && user.item.is_berry?
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || !user.item || !user.item.is_berry?
    item = user.item
    @battle.pbDisplay(_INTL("{1} smashed and ate its {2}!", user.pbThis, user.itemName))
    user.pbConsumeItem(true, false)
    user.pbHeldItemTriggerCheck(item, false)
    user.pbSymbiosis if !user.item
  end
end

class PokeBattle_Move_KERD35 < PokeBattle_Move   # Triple Dive
  def multiHitMove?; return true; end
  def pbNumHits(user, targets); return 3; end
end

class PokeBattle_Move_KERD36 < PokeBattle_Move_11C   # Smite
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
  end
end

class PokeBattle_Move_KERD37 < PokeBattle_Move   # Jaw Lock
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted? || target.damageState.unaffected
    return if user.effects[PBEffects::MeanLook] >= 0 || target.effects[PBEffects::MeanLook] >= 0
    user.effects[PBEffects::MeanLook] = target.index
    target.effects[PBEffects::MeanLook] = user.index
    @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
  end
end

class PokeBattle_Move_KERD38 < PokeBattle_Move   # Excalibur
  def pbBaseDamage(baseDmg, user, target)
    return target.pbHasType?(:DRAGON) ? baseDmg * 2 : baseDmg
  end
end

class PokeBattle_Move_KERD39 < PokeBattle_Move   # Decorate
  def pbOnStartUse(user, targets)
    @kifer_buff = targets.length > 0 && !user.opposes?(targets[0])
  end

  def pbDamagingMove?
    return false if @kifer_buff
    return super
  end

  def pbFailsAgainstTarget?(user, target)
    return false if !@kifer_buff
    return false if [:ATTACK, :SPECIAL_ATTACK].any? { |s| target.pbCanRaiseStatStage?(s, user, self) } ||
                    target.effects[PBEffects::FocusEnergy] < 2
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbEffectAgainstTarget(user, target)
    return if !@kifer_buff
    anim = true
    [:ATTACK, :SPECIAL_ATTACK].each do |s|
      next if !target.pbCanRaiseStatStage?(s, user, self)
      anim = false if target.pbRaiseStatStage(s, 2, user, anim)
    end
    return if target.effects[PBEffects::FocusEnergy] >= 2
    target.effects[PBEffects::FocusEnergy] = 2
    @battle.pbDisplay(_INTL("{1} is getting pumped!", target.pbThis))
  end
end

# Safe Passage: 35% less damage for the Pokemon it brought in, that turn
class PokeBattle_Move
  alias kifer_nm4_pbCalcDamageMultipliers pbCalcDamageMultipliers unless method_defined?(:kifer_nm4_pbCalcDamageMultipliers)
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    kifer_nm4_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    multipliers[:final_damage_multiplier] *= 0.65 if KIFER::NewMoveFx4.safe?(@battle, target)
  end
end

#-------------------------------------------------------------------------------
# Thundercall – after an Electric move, a 24 power Smite (Glacial Rage's way)
#-------------------------------------------------------------------------------
BattleHandlers::UserAbilityEndOfMove.add(:THUNDERCALL,
  proc { |ability, user, targets, move, battle|
    next if user.instance_variable_get(:@kifer_f_extra)
    next if move.calcType != :ELECTRIC || user.fainted? || user.lastMoveFailed
    next if user.instance_variable_get(:@kifer_f_follow) || !GameData::Move.exists?(:SMITE)
    t = targets.find { |b| b.index != user.index && !b.fainted? && !b.damageState.unaffected }
    next if !t
    user.instance_variable_set(:@kifer_f_follow, [:SMITE, t.index, 24, ability])
  }
)
KIFER.er_code(:THUNDERCALL, :CURRENTCRASH)

class PokeBattle_AI
  alias kifer_nmf4_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode unless method_defined?(:kifer_nmf4_pbGetMoveScoreFunctionCode)
  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    f = move && move.function
    as = KIFER::NewMoveFx4::AI_AS[f]
    return kifer_nmf4_pbGetMoveScoreFunctionCode(score, move, user, target, skill) if !as
    move.instance_variable_set(:@function, as)   # scored as the PIF move it works like
    begin
      return kifer_nmf4_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    ensure
      move.instance_variable_set(:@function, f)
    end
  end
end

KIFER::NewMoveFx4::AI_AS.each_key do |c|
  k = Object.const_get("PokeBattle_Move_#{c}")
  KIFER::TerrainEnrage.wrap_move_class(k) if defined?(KIFER::TerrainEnrage) && KIFER::TerrainEnrage.respond_to?(:wrap_move_class)
end

KIFER::Moves.coded(:CORROSIVEGAS, function_code: "KERD29")
KIFER::Moves.coded(:SCORCHEDEARTH, function_code: "KERD30")
KIFER::Moves.coded(:ELECTROSHOT, function_code: "KERD31")
KIFER::Moves.coded(:SAFEPASSAGE, function_code: "KERD32")
KIFER::Moves.coded(:MISTYEXPLOSION, function_code: "KERD33")
KIFER::Moves.coded(:BERRYSMASH, function_code: "KERD34")
KIFER::Moves.coded(:TRIPLEDIVE, function_code: "KERD35")
KIFER::Moves.coded(:SMITE, function_code: "KERD36")
KIFER::Moves.coded(:JAWLOCK, function_code: "KERD37")
KIFER::Moves.coded(:EXCALIBUR, function_code: "KERD38")
KIFER::Moves.coded(:BADEGG, function_code: "006")
KIFER::Moves.coded(:DECORATE, function_code: "KERD39")
KIFER::NewMoves.register   # in the game now (064)
