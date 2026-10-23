#===============================================================================
# With KIF: Elite Redux on, a Mega has its Elite Redux abilities: its own
# choice list and innates (types and stats: Megas.species_data).
# Through KIF-ER's kit API (KIFER.register_kit / refresh_battler, 0.6.4+).
#===============================================================================
module Megas
  # The Mega's ER kit for this Pokémon while it's Mega (or Primal), else nil
  def self.er_kit(pkmn)
    return nil if @in_kit   # fusion_er_kit is asking KIF-ER for the fusion's own innates
    id = current(pkmn)
    return fusion_er_kit(pkmn, id) if id.is_a?(Array)
    er = id && DATA[id][:er]
    return er ? { :choices => er[:choices].dup, :innates => er[:innates].dup } : nil
  end

  # A Mega fusion: head choices + body choices as for any fusion, with a Mega
  # half's ER kit in place of its base species'. Innates: KIF-ER's own pick for
  # the fusion, each one that came from a Mega half swapped for that Mega's
  # innate in the same place (KIF-ER 0.6.22+ says which half each pick came
  # from; older ones: the first match, wrong for Charizard x Charizard).
  def self.fusion_er_kit(pkmn, ids)
    base = pkmn.megas_species_data
    halves = [base.head_pokemon.id, base.body_pokemon.id]
    # a Mega half's list has its base species' length: KIF-ER finds the head's
    # share of a fusion's list by the head species (Mega Charizard X's one
    # ability fills Charizard's three places, as ER lists it three times)
    choices = [0, 1].flat_map do |i|
      own = KIFER.choices_of(halves[i])
      next own if !ids[i]
      mine = DATA[ids[i]][:er][:choices]
      own.empty? ? mine : Array.new(own.length) { |k| mine[k % mine.length] }
    end
    inn = begin
      @in_kit = true
      KIFER.pokemon_innates(pkmn)
    ensure
      @in_kit = false
    end
    at = KIFER.respond_to?(:picked_at) && KIFER.picked_at(pkmn)
    if at && at.length == inn.length
      n = KIFER.species_innates(halves[0]).length   # head's share of the pool
      inn = inn.each_with_index.map do |a, p|
        i = at[p] < n ? 0 : 1
        ids[i] ? (DATA[ids[i]][:er][:innates][at[p] - i * n] || a) : a
      end
      return { :choices => choices, :innates => inn }
    end
    done = Array.new(inn.length, false)
    [0, 1].each do |i|
      next if !ids[i]
      from = KIFER.species_innates(halves[i])
      to = DATA[ids[i]][:er][:innates]
      used = []
      inn.each_index do |p|
        next if done[p]
        j = (0...from.length).find { |k| from[k] == inn[p] && !used.include?(k) }
        next if !j
        used << j
        inn[p] = to[j] || inn[p]
        done[p] = true
      end
    end
    return { :choices => choices, :innates => inn }
  end
end

if defined?(::KIFER) && KIFER.respond_to?(:register_kit)
  KIFER.register_kit("Megas") { |pkmn| Megas.er_kit(pkmn) }

  # A battler gets its innates when it is sent out; Mega Evolving swaps them
  class PokeBattle_Battler
    alias megas_pbUpdate pbUpdate unless method_defined?(:megas_pbUpdate)
    def pbUpdate(fullChange = false)
      megas_pbUpdate(fullChange)
      KIFER.refresh_battler(self) if fullChange && @pokemon && Megas.current(@pokemon)
    end
  end
end
