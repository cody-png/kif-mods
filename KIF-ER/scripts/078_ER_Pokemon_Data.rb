#===============================================================================
# KIF: Elite Redux – setting "Pokemon data" (Cody, 2026-10-22: one setting,
# On by default)
#   On: every PIF species takes Elite Redux's base stats and types
#   (data/er_stats.rb: 328 species change stats, 48 change types, e.g. Flygon
#   Ground/Bug). Fusions follow by themselves: PIF builds a fusion's stats and
#   types from its head and body each time it's looked up.
#   Off: PIF's own values come back.
#   The party and the boxes get their stats recalculated whenever the data
#   they were calculated with changes (setting changed, a save made before
#   the mod or with the other value): $PokemonGlobal remembers which.
#   Megas mod: KIFER::PokemonData.er_form(:VENUSAUR_MEGA) gives ER's stats and
#   types for a Mega while the setting is On (Library request).
#===============================================================================
module KIFER
  module PokemonData
    SETTING = :kifer_pokemon_data   # 0 = Off, 1 = On
    STATS = [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]

    @saved   = nil   # id => [base_stats, type1, type2] as the game had them
    @written = nil   # id => [base_stats, type1, type2] as set here
    @data    = nil   # the GameData::Species::DATA the values were saved from
    @applied = false

    module_function

    def register_setting
      ::ModSettingsMenu.register_enum(SETTING, "Pokemon data", ["Off", "On"], 1,
        "Elite Redux base stats and types for every Pokemon (and so their fusions).", KIFER::CATEGORY)
      if ::ModSettingsMenu.respond_to?(:register_on_change)
        ::ModSettingsMenu.register_on_change(SETTING) { |_v| KIFER::PokemonData.sync }
      end
    end

    def on?
      return KIFER.setting(SETTING, 1) == 1
    end

    def applied?; return @applied; end

    # ER's [stats hash, [types]] for a Mega / Primal form (Megas mod), nil while Off
    def er_form(id)
      return nil unless on?
      e = KIFER::ER_FORM_STATS[id.to_s.upcase.to_sym]
      return e ? [Hash[STATS.zip(e[0])], e[1].dup] : nil
    end

    # Puts the species data in the state the setting asks for, then the
    # Pokemon's stats. Cheap when nothing changed.
    def sync
      return unless defined?(GameData::Species::DATA) && !GameData::Species::DATA.empty?
      data = GameData::Species::DATA
      if !data.equal?(@data)   # a data (re)load: fresh PIF values
        @saved, @written, @data, @applied = nil, nil, data, false
      end
      want = on?
      if want != @applied
        want ? apply : restore
        @applied = want
        KIF::Perf.bump_token if defined?(KIF::Perf)   # Pokemon cache their fused species data
      end
      refresh_pokemon
    end

    def apply
      data = GameData::Species::DATA
      @saved ||= {}
      @written = {}
      KIFER::SPECIES_STATS.each do |id, (stats, types)|
        sp = data[id] or next
        t1 = types[0]; t2 = types[1] || t1
        next unless GameData::Type.exists?(t1) && GameData::Type.exists?(t2)
        @saved[id] ||= [sp.base_stats.dup, sp.type1, sp.type2]
        bs = Hash[STATS.zip(stats)]
        sp.instance_variable_set(:@base_stats, bs)
        sp.instance_variable_set(:@type1, t1)
        sp.instance_variable_set(:@type2, t2)
        @written[id] = [bs, t1, t2]
      end
    end

    # Only fields that still hold this module's values go back (the
    # randomizer's later changes stay)
    def restore
      return unless @saved && @written
      data = GameData::Species::DATA
      @written.each do |id, (bs, t1, t2)|
        sp = data[id] or next
        old = @saved[id]
        sp.instance_variable_set(:@base_stats, old[0].dup) if sp.base_stats.equal?(bs)
        if sp.type1 == t1 && sp.type2 == t2
          sp.instance_variable_set(:@type1, old[1])
          sp.instance_variable_set(:@type2, old[2])
        end
      end
      @written = nil
    end

    # Recalculates the party's and the boxes' stats when they were last
    # calculated with the other data
    def refresh_pokemon
      return unless defined?($PokemonGlobal) && $PokemonGlobal
      return if $PokemonGlobal.instance_variable_get(:@kifer_pd_stamp) == @applied
      each_pokemon { |pk| pk.calc_stats }
      $PokemonGlobal.instance_variable_set(:@kifer_pd_stamp, @applied)
    rescue StandardError => e
      KIFER.log("Pokemon data: stats not recalculated: #{e.class}: #{e.message}")
    end

    def each_pokemon
      list = []
      list.concat($Trainer.party.compact) if defined?($Trainer) && $Trainer && $Trainer.party
      if defined?($PokemonStorage) && $PokemonStorage
        $PokemonStorage.maxBoxes.times do |b|
          $PokemonStorage.maxPokemon(b).times { |s| pk = $PokemonStorage[b, s]; list << pk if pk }
        end
      end
      list.each { |pk| yield pk unless pk.egg? }
    end
  end
end

# After a save loads (the map scene starts) and before each battle
Events.onMapSceneChange += proc { |_sender, _e| KIFER::PokemonData.sync } if defined?(Events) && Events.respond_to?(:onMapSceneChange)

class PokeBattle_Battle
  alias kifer_pd_pbStartBattle pbStartBattle unless method_defined?(:kifer_pd_pbStartBattle)
  def pbStartBattle
    KIFER::PokemonData.sync
    return kifer_pd_pbStartBattle
  end
end

KIF::DataLoad.after_load_all("KIF-ER: Elite Redux Pokemon data") { KIFER::PokemonData.sync } if defined?(KIF::DataLoad)

begin
  if defined?(::ModSettingsMenu) && ::ModSettingsMenu.respond_to?(:register_enum)
    KIFER::PokemonData.register_setting
  else
    $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
    $MOD_SETTINGS_PENDING_REGISTRATIONS << proc { KIFER::PokemonData.register_setting }
  end
rescue StandardError => e
  KIFER.log("Pokemon data setting not registered: #{e.class}: #{e.message}")
end
KIFER::PokemonData.sync
