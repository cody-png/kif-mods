#===============================================================================
# KIF: Elite Redux – setting "Item changes" (Cody, 2026-10-23: only ER's
# confirmed changes to items PIF has; no new items, no game-wide rules)
#   Type-boost items and incenses x1.3 (PIF x1.2); Muscle Band / Wise Glasses
#   x1.15 (x1.1); Figy, Wiki, Mago, Aguav, Iapapa heal 1/2 at 1/4 HP (PIF: 1/8
#   at 1/2); Sun / Rain / Sand / Hail from a move last 8 turns, 12 with its
#   rock (PIF 5 / 8; ability weather stays as it was); Super Potion and Energy
#   Powder heal 60 (50); Light Ball works for Raichu too; Shell Bell heals 1/4
#   of the damage dealt (1/8); ER's prices (ROM, 96 items; not Rare Candy).
#   Source: Elite Redux 2.65.4.1b's item table (ROM).
#===============================================================================
module KIFER
  module ItemChanges
    SETTING = :kifer_item_changes   # 0 = Off, 1 = On

    BOOST = {   # item => [PIF's multiplier, ER's]
      :SILVERPOWDER => [1.2, 1.3], :METALCOAT => [1.2, 1.3], :SOFTSAND => [1.2, 1.3],
      :HARDSTONE => [1.2, 1.3], :MIRACLESEED => [1.2, 1.3], :BLACKGLASSES => [1.2, 1.3],
      :BLACKBELT => [1.2, 1.3], :MAGNET => [1.2, 1.3], :MYSTICWATER => [1.2, 1.3],
      :SHARPBEAK => [1.2, 1.3], :POISONBARB => [1.2, 1.3], :NEVERMELTICE => [1.2, 1.3],
      :SPELLTAG => [1.2, 1.3], :TWISTEDSPOON => [1.2, 1.3], :CHARCOAL => [1.2, 1.3],
      :DRAGONFANG => [1.2, 1.3], :SILKSCARF => [1.2, 1.3],
      :SEAINCENSE => [1.2, 1.3], :WAVEINCENSE => [1.2, 1.3], :ODDINCENSE => [1.2, 1.3],
      :ROCKINCENSE => [1.2, 1.3], :ROSEINCENSE => [1.2, 1.3],
      :MUSCLEBAND => [1.1, 1.15], :WISEGLASSES => [1.1, 1.15]
    }
    WEATHERS = [:Sun, :Rain, :Sandstorm, :Hail]
    POTION_HP = 60
    PRICES = {
      :ABILITYCAPSULE => 4000, :ABSORBBULB => 1000, :BALMMUSHROOM => 15000, :BERRYJUICE => 200,
      :BIGMUSHROOM => 5000, :BIGPEARL => 8000, :BLACKFLUTE => 20, :BLUEFLUTE => 20,
      :BLUESHARD => 1000, :BUGGEM => 500, :CALCIUM => 5000, :CARBOS => 5000,
      :CELLBATTERY => 1000, :COMETSHARD => 60000, :COVERFOSSIL => 7000, :DARKGEM => 500,
      :DAWNSTONE => 3000, :DRAGONGEM => 500, :DREAMBALL => 2000, :DUSKSTONE => 3000,
      :ELECTRICGEM => 500, :EVERSTONE => 3000, :FAIRYGEM => 500, :FASTBALL => 2000,
      :FIGHTINGGEM => 500, :FIREGEM => 500, :FIRESTONE => 3000, :FLYINGGEM => 500,
      :FOCUSSASH => 5000, :FRIENDBALL => 2000, :GHOSTGEM => 500, :GRASSGEM => 500,
      :GREENSHARD => 1000, :GROUNDGEM => 500, :HEAVYBALL => 2000, :HONEY => 300,
      :HPUP => 5000, :ICEGEM => 500, :ICESTONE => 3000, :IRON => 5000,
      :LEAFSTONE => 3000, :LEMONADE => 400, :LEVELBALL => 2000, :LOVEBALL => 2000,
      :LUMINOUSMOSS => 1000, :LUREBALL => 2000, :MAXREPEL => 650, :MENTALHERB => 100,
      :MOONBALL => 2000, :MOONSTONE => 3000, :NESTBALL => 1000, :NORMALGEM => 500,
      :ODDKEYSTONE => 2100, :OLDAMBER => 10000, :OVALSTONE => 2100, :PEARL => 2000,
      :PLUMEFOSSIL => 7000, :POISONGEM => 500, :POWERANKLET => 2000, :POWERBAND => 2000,
      :POWERBELT => 2000, :POWERBRACER => 2000, :POWERHERB => 2000, :POWERLENS => 2000,
      :POWERWEIGHT => 2000, :PREMIERBALL => 20, :PROTEIN => 5000, :PSYCHICGEM => 500,
      :RAREBONE => 5000, :REDFLUTE => 20, :REDSHARD => 1000, :RELICBAND => 200000,
      :RELICGOLD => 20000, :RELICSILVER => 10000, :RELICSTATUE => 400000, :RELICVASE => 100000,
      :REPEL => 350, :ROCKGEM => 500, :SHEDSHELL => 500, :SHINYSTONE => 3000,
      :SNOWBALL => 1000, :STARDUST => 3000, :STARPIECE => 12000, :STEELGEM => 500,
      :SUNSTONE => 3000, :THUNDERSTONE => 3000, :TINYMUSHROOM => 500, :UPGRADE => 2100,
      :WATERGEM => 500, :WATERSTONE => 3000, :WEAKNESSPOLICY => 4000, :WHITEFLUTE => 20,
      :WHITEHERB => 2000, :YELLOWFLUTE => 20, :YELLOWSHARD => 1000, :ZINC => 5000,
    }
    TEXTS = {
      :SUPERPOTION  => "A spray-type medicine for wounds. It restores the HP of one Pokémon by 60 points.",
      :ENERGYPOWDER => "A very bitter medicine powder. It restores the HP of one Pokémon by 60 points.",
      :LIGHTBALL    => "An item to be held by Pikachu or Raichu. It is a puzzling orb that raises the Attack and Sp. Atk stat.",
      :SHELLBELL    => "An item to be held by a Pokémon. The holder's HP is restored by 1/4 of the damage it inflicts."
    }

    module_function

    def register_setting
      ::ModSettingsMenu.register_enum(SETTING, "Item changes", ["Off", "On"], 1,
        "Elite Redux's changes to items: stronger boost items and berries, longer weather, prices.", KIFER::CATEGORY)
    end

    def on?
      return KIFER.setting(SETTING, 1) == 1
    end

    # On: mine; Off: the game's own handler (whatever was there before this file)
    def swap(handlers, id, mine)
      orig = handlers[id]
      return if !orig || orig.instance_variable_get(:@kifer_ic)
      wrapped = proc { |*a| KIFER::ItemChanges.on? ? mine.call(orig, *a) : orig.call(*a) }
      wrapped.instance_variable_set(:@kifer_ic, true)
      handlers.add(id, wrapped)
    end

    def install
      BOOST.each do |id, (pif, er)|
        swap(BattleHandlers::DamageCalcUserItem, id, proc { |orig, item, user, target, move, mults, baseDmg, type|
          before = mults[:base_damage_multiplier]
          orig.call(item, user, target, move, mults, baseDmg, type)
          mults[:base_damage_multiplier] *= er / pif if mults[:base_damage_multiplier] != before
        })
      end
      swap(BattleHandlers::DamageCalcUserItem, :LIGHTBALL, proc { |orig, item, user, target, move, mults, baseDmg, type|
        orig.call(item, user, target, move, mults, baseDmg, type)
        mults[:attack_multiplier] *= 2 if !user.isFusionOf(:PIKACHU) && user.isFusionOf(:RAICHU)
      })
      swap(BattleHandlers::UserItemAfterMoveUse, :SHELLBELL, proc { |_orig, item, user, targets, move, numHits, battle|
        next if !user.canHeal?
        total = targets.sum { |b| b.damageState.totalHPLost }
        next if total <= 0
        user.pbRecoverHP(total / 4)
        battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!", user.pbThis, user.itemName))
      })
      [:SUPERPOTION, :ENERGYPOWDER].each do |id|
        swap(ItemHandlers::UseOnPokemon, id, proc { |_orig, item, pkmn, scene|
          next false if !pbHPItem(pkmn, POTION_HP, scene)
          pkmn.changeHappiness("powder") if id == :ENERGYPOWDER
          next true
        })
        swap(ItemHandlers::BattleUseOnPokemon, id, proc { |_orig, item, pokemon, battler, choices, scene|
          pokemon.changeHappiness("powder") if pbBattleHPItem(pokemon, battler, POTION_HP, scene) && id == :ENERGYPOWDER
        })
      end
    end
  end
end

# Figy, Wiki, Mago, Aguav, Iapapa (PIF's Gen 7 branch: at 1/4 HP, 1/2 healed)
alias kifer_ic_pbBattleConfusionBerry pbBattleConfusionBerry unless Object.private_method_defined?(:kifer_ic_pbBattleConfusionBerry) || Object.method_defined?(:kifer_ic_pbBattleConfusionBerry)
def pbBattleConfusionBerry(battler, battle, item, forced, flavor, confuseMsg)
  return kifer_ic_pbBattleConfusionBerry(battler, battle, item, forced, flavor, confuseMsg) if !KIFER::ItemChanges.on?
  return false if !forced && !battler.canHeal?
  return false if !forced && !battler.canConsumePinchBerry?(true)
  itemName = GameData::Item.get(item).name
  battle.pbCommonAnimation("EatBerry", battler) if !forced
  amt = battler.pbRecoverHP(battler.totalhp / 2)
  if amt > 0
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
    end
  end
  flavor_stat = [:ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE][flavor]
  battler.nature.stat_changes.each do |change|
    next if change[1] > 0 || change[0] != flavor_stat
    battle.pbDisplay(confuseMsg)
    battler.pbConfuse if battler.pbCanConfuseSelf?(false)
    break
  end
  return true
end

class PokeBattle_Battle
  # Weather from a move: 8 turns, 12 with its rock (ER's rule for all weather;
  # 061 does the same for ER's own weather moves while this is Off)
  alias kifer_ic_pbStartWeather pbStartWeather unless method_defined?(:kifer_ic_pbStartWeather)
  def pbStartWeather(user, newWeather, *args)
    was = @field.weather
    ret = kifer_ic_pbStartWeather(user, newWeather, *args)
    f = @field
    if KIFER::ItemChanges.on? && f.weather != was && KIFER::ItemChanges::WEATHERS.include?(f.weather) && f.weatherDuration > 0
      f.weatherDuration = KIFER::MoveFxField.er_turns(f.weatherDuration)
    end
    return ret
  end
end

module GameData
  class Item
    alias kifer_ic_price price unless method_defined?(:kifer_ic_price)
    def price
      return (KIFER::ItemChanges.on? && KIFER::ItemChanges::PRICES[@id]) || kifer_ic_price
    end

    alias kifer_ic_description description unless method_defined?(:kifer_ic_description)
    def description
      return (KIFER::ItemChanges.on? && KIFER::ItemChanges::TEXTS[@id]) || kifer_ic_description
    end
  end
end

KIFER::ItemChanges.install

begin
  if defined?(::ModSettingsMenu) && ::ModSettingsMenu.respond_to?(:register_enum)
    KIFER::ItemChanges.register_setting
  else
    $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
    $MOD_SETTINGS_PENDING_REGISTRATIONS << proc { KIFER::ItemChanges.register_setting }
  end
rescue StandardError => e
  KIFER.log("Item changes setting not registered: #{e.class}: #{e.message}")
end
