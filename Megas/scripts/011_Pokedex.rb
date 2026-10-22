#===============================================================================
# The Pokédex page opened from the Summary (Cody, 2026-10-21): while the
# Pokémon is Mega or Primal, it shows the Mega's name, category, height,
# weight and entry (pokeemerald-expansion's text, data/megas_dex.rb). Elite
# Redux has no entries for its Megas; those, Mega fusions and the Pokédex
# itself keep the base species' page.
#===============================================================================
module Megas
  class << self
    attr_accessor :dex_view   # the Mega page's species data while the page draws
  end

  # The base species' data with the Mega's Pokédex fields, or nil
  def self.dex_data(id, base)
    d = DEX[id]
    return nil if !d
    sd = base.clone
    sd.instance_variable_set(:@megas_dex, [DATA[id][:name], d[0], d[3]])
    sd.instance_variable_set(:@height, d[1])
    sd.instance_variable_set(:@weight, d[2])
    return sd
  end
end

module GameData
  class Species
    alias megas_name name unless method_defined?(:megas_name)
    def name;          return @megas_dex ? @megas_dex[0] : megas_name;          end
    alias megas_category category unless method_defined?(:megas_category)
    def category;      return @megas_dex ? @megas_dex[1] : megas_category;      end
    alias megas_pokedex_entry pokedex_entry unless method_defined?(:megas_pokedex_entry)
    def pokedex_entry; return @megas_dex ? @megas_dex[2] : megas_pokedex_entry; end

    class << self
      alias megas_get_species_form get_species_form unless method_defined?(:megas_get_species_form)
      def get_species_form(species, form)
        v = Megas.dex_view
        return v if v && species == v.id
        return megas_get_species_form(species, form)
      end
    end
  end
end

class PokemonPokedexInfo_Scene
  alias megas_drawPageInfo drawPageInfo unless method_defined?(:megas_drawPageInfo)
  def drawPageInfo(*args)
    pk = @pokemon
    id = pk && @fromSummary && @dexlist && pk.species == @dexlist[@index][0] ? Megas.current(pk) : nil
    view = id && !id.is_a?(Array) ? Megas.dex_data(id, pk.species_data) : nil   # the Mega's types too
    return megas_drawPageInfo(*args) if !view
    Megas.dex_view = view
    begin
      return megas_drawPageInfo(*args)
    ensure
      Megas.dex_view = nil
    end
  end
end
