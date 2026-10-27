#===============================================================================
# Mega fusions (Cody, 2026-10-20: option C, the overlay; no new species).
#   * The fusion holds one stone: the half it fits Mega Evolves. If the
#     player's bag has a stone for the other half, that half goes Mega too
#     (Mega Charizard x Mega Blastoise). Trainers never do Mega + Mega.
#   * A stone that fits both halves (Charizard x Charizard): both halves Mega
#     with a second copy in the bag; otherwise the half the DNA Splicer asked
#     for when fusing (@megas_fusion_half, :head by default).
#   * The fused data is PIF's own FusedSpecies with the Mega half (or halves)
#     swapped in, so PIF's fusion rules (dominant stats, types) apply.
#   * The self-fusion boost only for matching Megas (X x X, never X x Y).
#   * Stats (Cody, 2026-10-26, setting "Mega fusion stats"): Full, the default,
#     adds each Mega half's whole boost to the plain fusion (one half +100
#     BST, both +200); Split uses PIF's 2/3 + 1/3 share with the Mega half in.
#   * Sprite (Cody, 2026-10-22): both halves' own sprites drawn together,
#     striped where they overlap, with the Mega badge (striped_fusion). Only
#     when a half's sprite is missing: the fusion sprite + badge + aura.
# State: @megas_form = [head Mega id or nil, body Mega id or nil].
#===============================================================================
module Megas
  def self.fusion_halves(pkmn)
    base = pkmn.megas_species_data
    return [] if !base.respond_to?(:head_pokemon) || !base.head_pokemon
    return [base.head_pokemon.id, base.body_pokemon.id]
  end

  def self.player_owns?(pkmn)
    return $Trainer && $Trainer.party.any? { |p| p.equal?(pkmn) }
  end

  def self.in_bag?(item)
    return $PokemonBag && $PokemonBag.respond_to?(:pbQuantity) && $PokemonBag.pbQuantity(item) > 0
  end

  # [head id, body id] this fusion could turn into now, or nil
  def self.fusion_available(pkmn, kind = :mega)
    return nil if pkmn.respond_to?(:isTripleFusion?) && pkmn.isTripleFusion?
    base = pkmn.megas_species_data
    return nil if !base.respond_to?(:head_pokemon) || !base.head_pokemon || !base.body_pokemon
    halves = [base.head_pokemon.id, base.body_pokemon.id]
    item = pkmn.instance_variable_get(:@item)
    kinds = lambda { |m| (m[:primal] ? :primal : :mega) == kind && usable?(m) }
    held = halves.map do |sp|
      (by_base[sp] || []).find { |_i, m| kinds.call(m) && (m[:stone] ? m[:stone] == item : pkmn.hasMove?(m[:move])) }
    end
    return nil if !held[0] && !held[1]
    i = if !held[0] || !held[1] then (held[0] ? 0 : 1)
        elsif !held[0][1][:stone] != !held[1][1][:stone] then (held[0][1][:stone] ? 0 : 1)   # stone beats a move (Dragon Ascent)
        else (pkmn.instance_variable_get(:@megas_fusion_half) == :body ? 1 : 0) end   # one stone fits both
    ids = [nil, nil]
    ids[i] = held[i][0]
    if kind == :mega && player_owns?(pkmn)
      other = halves[1 - i]
      found = (by_base[other] || []).select { |_i, m| kinds.call(m) && m[:stone] && in_bag?(m[:stone]) }
      found = found.sort_by { |_i, m| m[:stone] == item ? 0 : 1 }   # the same stone first (X x X)
      ids[1 - i] = found[0][0] if found[0]
    end
    return ids
  end

  @fusion_cache = {}

  # PIF's FusedSpecies for this fusion with the Mega half (or halves) in
  def self.fusion_species_data(ids, base)
    er = er?
    full = full_boost?
    key = [base.object_id, base.base_stats.hash, er, full, (defined?(KIF::Perf) ? KIF::Perf.token : nil)]
    hit = @fusion_cache[[ids, base.id]]   # two fusions with the same Mega half don't evict each other
    return hit[1] if hit && hit[0] == key
    sd = base.clone
    head = ids[0] ? species_data(ids[0], base.head_pokemon) : base.head_pokemon
    body = ids[1] ? species_data(ids[1], base.body_pokemon) : base.body_pokemon
    sd.instance_variable_set(:@head_pokemon, head)
    sd.instance_variable_set(:@body_pokemon, body)
    sd.instance_variable_set(:@type1, sd.send(:calculate_type1))
    sd.instance_variable_set(:@type2, sd.send(:calculate_type2))
    stats = sd.send(:calculate_base_stats)
    if full   # each Mega half adds its whole boost to the plain fusion, not a 2/3 or 1/3 share
      stats = base.base_stats.dup
      [[head, base.head_pokemon], [body, base.body_pokemon]].each_with_index do |(mega, plain), i|
        next if !ids[i]
        mega.base_stats.each { |s, v| stats[s] = [stats[s] + v - plain.base_stats[s], 1].max }
      end
    end
    sd.instance_variable_set(:@base_stats, stats)
    sd.instance_variable_set(:@abilities, sd.send(:calculate_abilities))
    sd.instance_variable_set(:@hidden_abilities, sd.send(:calculate_hidden_abilities))
    sd.instance_variable_set(:@real_name, _INTL("Mega {1}", base.real_name))
    sd.instance_variable_set(:@mega_stone, ids.compact.map { |i| DATA[i][:stone] }.compact.first)
    @fusion_cache[[ids, base.id]] = [key, sd]
    return sd
  end

  # The Mega half's ability (both Mega: PIF's ability slot picks: 1 = head,
  # otherwise body). KIF:ER on: the Pokémon's ER pick when it's coded.
  def self.fusion_ability(pkmn, ids)
    if er?
      er = KIFER.chosen_ability(pkmn) rescue nil
      return er if er && GameData::Ability.exists?(er)
    end
    head = ids[0] && DATA[ids[0]]
    body = ids[1] && DATA[ids[1]]
    pick = lambda { |m| m && (m[:er_only] ? m[:er][:choices].find { |a| GameData::Ability.exists?(a) } : m[:ability]) }
    first, second = pkmn.ability_index == 1 ? [head, body] : [body, head]
    return pick.call(first) || pick.call(second)
  end

  # A Mega fusion's sprite: the two halves' sprites (a Mega half its Mega's,
  # the other its species' normal one) on one 288 px canvas, centred, feet on
  # the body's ground line. Where both cover a pixel, sprite-pixel rows (3 game
  # rows) alternate: even = body, odd = head (Cody: one sprite pixel, so the
  # stripes stay even when screens draw sprites at 2/3). nil = a half has no
  # sprite. Shiny: the striped sprite takes the fusion's hue; the badge after.
  STRIPE = 3 unless defined?(STRIPE)
  CANVAS = 288 unless defined?(CANVAS)

  def self.striped_fusion(pkmn, ids, make_shiny = true)
    halves = fusion_halves(pkmn)
    return nil if halves.length < 2
    anims = [0, 1].map do |i|
      next GameData::Species.front_sprite_bitmap(halves[i]) if !ids[i]
      path = sprite_path(ids[i])
      path && AnimatedBitmap.new(path)
    end
    head, body = anims.map { |a| a && a.bitmap && game_scale(a.bitmap) }
    out = nil
    if head && body && head.respond_to?(:raw_data) && body.respond_to?(:raw_data)
      c = CANVAS
      bx = (c - body.width) / 2 / STRIPE * STRIPE
      by = c - body.height   # where the game puts it alone (bottom-aligned)
      hx = (c - head.width) / 2 / STRIPE * STRIPE
      hy = ((by + feet(body) - feet(head)) / STRIPE.to_f).round * STRIPE
      out = Bitmap.new(c, c)
      out.blt(hx, hy, head, head.rect)
      out.blt(bx, by, body, body.rect)
      (STRIPE...c).step(2 * STRIPE) do |y|   # odd rows: the head back on top where it covers
        ys = [y, hy].max
        ye = [y + STRIPE, hy + head.height].min
        out.blt(hx, ys, head, Rect.new(0, ys - hy, head.width, ye - ys)) if ye > ys
      end
    end
    anims.each_with_index do |a, i|
      next if !a
      scaled = [head, body][i]
      scaled.dispose if scaled && !a.bitmap.equal?(scaled)
      a.dispose
    end
    return nil if !out
    anim = AnimatedBitmap.from_bitmap(out)
    make_shiny!(anim, pkmn) if make_shiny && pkmn.shiny?
    return decorate!(anim, false)
  end

  # A sprite at game scale (PIF's base sprites mix 96 px files and 3x ones)
  def self.game_scale(bmp)
    return bmp if bmp.width > 96
    big = Bitmap.new(bmp.width * 3, bmp.height * 3)
    big.stretch_blt(big.rect, bmp, bmp.rect)
    return big
  end

  # Rows down to the bottom of a sprite's opaque area (its feet)
  def self.feet(bmp)
    w = bmp.width
    px = bmp.raw_data.unpack("N*")
    (bmp.height - 1).downto(0) { |y| return y + 1 if (y * w...(y + 1) * w).any? { |k| (px[k] & 0xFF) != 0 } }
    return bmp.height
  end

  # Mega badge (and aura) on a fusion's sprite. Drawn on a private copy, in
  # sprite pixels (the bitmap's own scale).
  AURA_INNER = 0x78C8FFFF unless defined?(AURA_INNER)   # light blue
  AURA_OUTER = 0x7846C8FF unless defined?(AURA_OUTER)   # purple

  def self.decorate!(anim, aura = true)
    if defined?(KIF::Shiny) && KIF::Shiny.respond_to?(:privatize)
      KIF::Shiny.privatize(anim)
    else
      anim.bitmap = anim.bitmap.clone
    end
    bmp = anim.bitmap
    return anim if !bmp.respond_to?(:raw_data)
    w = bmp.width
    h = bmp.height
    s = (w % 96 == 0 && w >= 96) ? w / 96 : 1   # PIF draws 96px sprites at 3x
    cw = w / s
    ch = h / s
    px = bmp.raw_data.unpack("N*")
    if aura
      solid = Array.new(cw * ch) { |k| (px[(k / cw) * s * w + (k % cw) * s] & 0xFF) != 0 }
      grow = lambda do |mask|
        out = mask.dup
        mask.each_index do |k|
          next if !mask[k]
          x = k % cw
          y = k / cw
          out[k - 1] = true if x > 0
          out[k + 1] = true if x < cw - 1
          out[k - cw] = true if y > 0
          out[k + cw] = true if y < ch - 1
        end
        out
      end
      ring1 = grow.call(solid)
      ring2 = grow.call(ring1)
      paint = lambda do |k, color|
        x0 = (k % cw) * s
        y0 = (k / cw) * s
        s.times { |dy| s.times { |dx| i = (y0 + dy) * w + x0 + dx; px[i] = color if (px[i] & 0xFF) == 0 } }
      end
      ring2.each_index do |k|
        next if solid[k] || !ring2[k]
        paint.call(k, ring1[k] ? AURA_INNER : AURA_OUTER)
      end
    end
    badge = (Bitmap.new("Graphics/Pictures/Battle/icon_mega") rescue nil)
    if badge && badge.respond_to?(:raw_data)
      bpx = badge.raw_data.unpack("N*")
      bw = badge.width
      bpx.each_with_index do |c, k|
        next if (c & 0xFF) == 0
        s.times { |dy| s.times { |dx| x = 2 * s + (k % bw) * s + dx; y = 2 * s + (k / bw) * s + dy; px[y * w + x] = c if x < w && y < h } }
      end
      badge.dispose
    end
    bmp.raw_data = px.pack("N*")
    return anim
  end
end

# The DNA Splicer asks which half goes Mega when one stone fits both halves
# (only for a Mega or Primal that can be used now)
alias megas_pbFuse pbFuse unless Object.method_defined?(:megas_pbFuse) || Object.private_method_defined?(:megas_pbFuse)
def pbFuse(pokemon_body, pokemon_head, *args)
  # back to normal first, while each one's parked KIF-ER pick still matches its species
  [pokemon_body, pokemon_head].each { |pk| pk.makeUnmega if pk.is_a?(Pokemon) }
  fits = pokemon_body.species == pokemon_head.species ? (Megas.by_base[pokemon_body.species] || []).select { |_i, m| m[:stone] && Megas.usable?(m) } : []
  ret = megas_pbFuse(pokemon_body, pokemon_head, *args)
  if ret && !fits.empty?
    text = if fits.all? { |_i, m| m[:primal] }
             _INTL("Its orb fits both halves. When {1} holds it, which half should undergo Primal Reversion?", pokemon_body.name)
           else
             _INTL("A Mega Stone fits both halves. When {1} holds one, which half should Mega Evolve?", pokemon_body.name)
           end
    cmd = pbMessage(text, [_INTL("Head"), _INTL("Body")], 1)
    pokemon_body.instance_variable_set(:@megas_fusion_half, cmd == 1 ? :body : :head)
  end
  return ret
end

class Pokemon
  # Self-fusion boost (KIF option): only while both halves are the same Mega
  if method_defined?(:kif_self_fusion_factor)
    alias megas_kif_self_fusion_factor kif_self_fusion_factor unless method_defined?(:megas_kif_self_fusion_factor)
    def kif_self_fusion_factor
      id = Megas.current(self)
      return nil if id.is_a?(Array) && (id[0].nil? || id[0] != id[1])
      return megas_kif_self_fusion_factor
    end
  end
end
