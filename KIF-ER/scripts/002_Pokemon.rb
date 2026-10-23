#===============================================================================
# KIF: Elite Redux – which innates a Pokémon has
#   Non-fusion: its species' 3 innates.
#   Fusion: 3 of its head's and body's 6, picked at random the first time and
#   kept on the Pokémon (@kifer_picked). Kept through
#   evolution; picked again once a pick isn't in the fusion's 6 any more.
#   Plain Ruby data, so saves load without the mod.
#   Triple fusions get none.
#===============================================================================
class Pokemon
  # Innates this Pokémon has (Symbols), whether or not the game implements them yet
  def innates
    return [] unless KIFER.enabled?
    return KIFER.pokemon_innates(self)
  rescue StandardError => e
    KIFER.log("innates failed for #{@species.inspect}: #{e.class}: #{e.message}")
    return []
  end

  # Replace a fusion's 3 picked innates (Summary screen, phase 2). By name only:
  # each pick's half is then the first match (KIFER.picked_at)
  def kifer_pick=(list)
    @kifer_picked = list.is_a?(Array) ? list.map { |a| a.to_sym }.first(3) : nil
    @kifer_picked_at = nil
  end
end

module KIFER
  #-----------------------------------------------------------------------------
  # Kits from other mods: a mod can give a Pokémon another ER kit (Megas: a
  # Mega's choices and innates). The first provider that answers a Hash wins:
  #   KIFER.register_kit("Megas") { |pkmn| mega?(pkmn) ? { :choices => [...], :innates => [...] } : nil }
  # After a mid-battle form change, KIFER.refresh_battler(battler) re-reads
  # the battler's innates.
  #-----------------------------------------------------------------------------
  @kit_providers = []

  def self.register_kit(owner, &block)
    @kit_providers.reject! { |o, _| o == owner }
    @kit_providers << [owner, block] if block
    return nil
  end

  def self.unregister_kit(owner)
    @kit_providers.reject! { |o, _| o == owner }
    return nil
  end

  def self.kit_for(pkmn)
    return nil if @kit_providers.empty? || !pkmn.is_a?(Pokemon)
    @kit_providers.each do |owner, block|
      begin
        k = block.call(pkmn)
        return k if k.is_a?(Hash)
      rescue StandardError => e
        log("kit from #{owner} failed: #{e.class}: #{e.message}")
      end
    end
    return nil
  end

  def self.refresh_battler(battler)
    return if !battler || !battler.pokemon
    battler.instance_variable_set(:@innate_ids, battle_innates(battler.pokemon))
  end

  def self.pokemon_innates(pkmn)
    return [] if pkmn.respond_to?(:egg?) && pkmn.egg?
    return [] if pkmn.respond_to?(:isTripleFusion?) && pkmn.isTripleFusion?
    kit = kit_for(pkmn)
    return kit[:innates].dup if kit && kit[:innates].is_a?(Array)
    return species_innates(pkmn.species) unless pkmn.isFusion?
    head = pkmn.get_head_species
    body = pkmn.get_body_species
    pool = fusion_pool(head.id, body.id)
    picked = pkmn.instance_variable_get(:@kifer_picked)
    fresh = picked.is_a?(Array) && !picked.empty? && KIFER.sub_multiset?(picked, pool)
    unless fresh
      idxs = (0...pool.length).to_a.sample([3, pool.length].min).sort
      picked = idxs.map { |i| pool[i] }                   # keep head-then-body order
      pkmn.instance_variable_set(:@kifer_picked, picked)
      pkmn.instance_variable_set(:@kifer_picked_at, idxs)
    end
    return picked.dup
  end

  # Where each of a fusion's picked innates sits in its pool (0-2 head, 3-5
  # body), so a self-fusion's picks keep their half (Megas: a Mega half swaps
  # only its own). Picks saved without places: the first match for each.
  def self.picked_at(pkmn)
    picked = pkmn.instance_variable_get(:@kifer_picked)
    return nil if !picked.is_a?(Array) || !pkmn.isFusion?
    pool = fusion_pool(pkmn.get_head_species.id, pkmn.get_body_species.id)
    at = pkmn.instance_variable_get(:@kifer_picked_at)
    return at.dup if at.is_a?(Array) && at.map { |i| pool[i] } == picked
    left = (0...pool.length).to_a
    return picked.map { |a| i = left.find { |k| pool[k] == a }; left.delete(i); i }
  end

  # Every item of `part` is in `whole`, counting copies
  def self.sub_multiset?(part, whole)
    left = whole.dup
    part.each do |a|
      i = left.index(a)
      return false unless i
      left.delete_at(i)
    end
    return true
  end

  # Innates that work in battle (the game has the ability)
  def self.battle_innates(pkmn)
    return [] unless enabled?
    return pkmn.innates.select { |a| GameData::Ability.exists?(a) }
  end
end
