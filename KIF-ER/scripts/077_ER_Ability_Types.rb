#===============================================================================
# KIF: Elite Redux – setting "Types from abilities" (Cody, 2026-10-22)
#   Elite Redux (default): Aquatic, Metallic, Phantom... add their type when
#     the Pokemon comes in (one added type at a time, as before).
#   PokeRogue Redux: the Pokemon simply has those types, as many as its main
#     ability and innates give (a 3rd, 4th... type), in battle from the start
#     and on the Summary. The entry effect then finds the type already there
#     and does nothing. No other new effect (Cody: none until players ask).
#   Turboblaze / Teravolt add their type only with Ability versions: Elite
#   Redux, as before. Monster Mash (a type for the foe) is unchanged.
#===============================================================================
module KIFER
  module AbilityTypes
    SETTING = :kifer_ability_types   # 0 = Elite Redux, 1 = PokeRogue Redux

    # abilities that add a type to their own Pokemon (composites too)
    TYPES = { :AQUATIC => :WATER, :WATERBORNE => :WATER, :GROUNDED => :GROUND,
              :HALFDRAKE => :DRAGON, :DRAGONFLY => :DRAGON, :METALLIC => :STEEL,
              :METALLICJAWS => :STEEL, :PHANTOM => :GHOST, :WITCHBROOM => :PSYCHIC }
    ER_VERSION_TYPES = { :TURBOBLAZE => :FIRE, :TERAVOLT => :ELECTRIC }

    module_function

    def register_setting
      ::ModSettingsMenu.register_enum(SETTING, "Types from abilities", ["Elite Redux", "PokeRogue Redux"], 0,
        "Elite Redux: abilities like Aquatic add their type on entry. PokeRogue Redux: the Pokemon always has those types.",
        KIFER::CATEGORY)
    end

    def prr?
      return KIFER.setting(SETTING, 0) == 1
    end

    def type_of(ability)
      t = TYPES[ability]
      t ||= ER_VERSION_TYPES[ability] if defined?(KIFER::ERVersions) && KIFER::ERVersions.on? && !dd_wins?(ability)
      return (t && GameData::Type.exists?(t)) ? t : nil
    end

    # Differentiating Duplicates' "This mod wins" runs its own Turboblaze / Teravolt
    def dd_wins?(ability)
      return defined?(::DiffDupes) && DiffDupes.respond_to?(:ability_on?) && DiffDupes.ability_on?(ability)
    end

    # Types the abilities give, besides the base ones (PokeRogue Redux only)
    def extra_types(abilities, base)
      return [] unless prr?
      return (abilities.compact.map { |a| type_of(a) }.compact - base).uniq
    end

    def for_pokemon(pkmn)
      return [] if !pkmn || pkmn.egg?
      return extra_types([pkmn.ability_id] + KIFER.battle_innates(pkmn), [pkmn.type1, pkmn.type2])
    rescue StandardError
      return []
    end
  end
end

class PokeBattle_Battler
  alias kifer_at_pbInitPokemon pbInitPokemon unless method_defined?(:kifer_at_pbInitPokemon)
  def pbInitPokemon(pkmn, idxParty)
    kifer_at_pbInitPokemon(pkmn, idxParty)
    begin
      abils = [@ability_id] + Array(@innate_ids)   # innates include a dual 2nd ability (010)
      @kifer_at_types = KIFER::AbilityTypes.extra_types(abils, [@type1, @type2])
    rescue StandardError => e
      @kifer_at_types = nil
      KIFER.log("ability types failed: #{e.class}: #{e.message}")
    end
  end

  alias kifer_at_pbTypes pbTypes unless method_defined?(:kifer_at_pbTypes)
  def pbTypes(withType3 = false)
    ret = kifer_at_pbTypes(withType3)
    extra = @kifer_at_types
    return ret if !extra || extra.empty?
    extra -= [:FIRE] if @effects[PBEffects::BurnUp]            # Burn Up
    extra -= [:ELECTRIC] if @kifer_nm5_shocked                # Double Shock (072)
    return ret | extra
  end

  # A move that sets the types (Soak, Reflect Type, Forest's Curse...) replaces these too
  alias kifer_at_pbChangeTypes pbChangeTypes unless method_defined?(:kifer_at_pbChangeTypes)
  def pbChangeTypes(newType)
    @kifer_at_types = newType.is_a?(PokeBattle_Battler) ? newType.instance_variable_get(:@kifer_at_types) : nil
    @kifer_at_types = @kifer_at_types.dup if @kifer_at_types
    return kifer_at_pbChangeTypes(newType)
  end
end

# Summary: every type on the Type row (narrower icons when they don't fit)
class PokemonSummary_Scene
  alias kifer_at_drawPageOne drawPageOne unless method_defined?(:kifer_at_drawPageOne)
  def drawPageOne
    kifer_at_drawPageOne
    kifer_at_draw_types
  end

  def kifer_at_draw_types
    extra = KIFER::AbilityTypes.for_pokemon(@pokemon)
    return if extra.empty?
    types = [@pokemon.type1, @pokemon.type2].uniq + extra
    overlay = @sprites["overlay"].bitmap
    y = 114
    left, right, gap = 296, 506, 2
    w = [64, (right - left - gap * (types.length - 1)) / types.length].min
    overlay.fill_rect(left, y, right - left, 28, Color.new(0, 0, 0, 0))   # the two icons drawn above
    x = right - types.length * w - (types.length - 1) * gap
    clear = Color.new(0, 0, 0, 0)
    cw = [(2 * w / 64.0).round, 1].max
    types.each do |t|
      src = Rect.new(0, GameData::Type.get(t).id_number * 28, 64, 28)
      overlay.stretch_blt(Rect.new(x, y, w, 28), @typebitmap.bitmap, src)
      # the sheet's white 2x2 corners show on the darker label column: round them off
      [[x, y], [x + w - cw, y], [x, y + 26], [x + w - cw, y + 26]].each { |cx, cy| overlay.fill_rect(cx, cy, cw, 2, clear) }
      x += w + gap
    end
  rescue StandardError => e
    KIFER.log("summary ability types failed: #{e.class}: #{e.message}")
  end
end

begin
  if defined?(::ModSettingsMenu) && ::ModSettingsMenu.respond_to?(:register_enum)
    KIFER::AbilityTypes.register_setting
  else
    $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
    $MOD_SETTINGS_PENDING_REGISTRATIONS << proc { KIFER::AbilityTypes.register_setting }
  end
rescue StandardError => e
  KIFER.log("Types from abilities setting not registered: #{e.class}: #{e.message}")
end
