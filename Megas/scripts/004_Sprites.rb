#===============================================================================
# Battle/summary sprite while Mega: the player's own image if there is one
# (Graphics/CustomBattlers/Megas in the game folder, never touched by updates),
# else the mod's own, shiny-shifted the way PIF shifts any sprite. No image for
# a Mega = the normal sprite.
#   <MEGA_ID>.png      a Mega (Mega Charizard X: CHARIZARD_MEGA_X.png)
#   <head>.<body>.png  a Mega fusion (dex numbers; <head>.<body>.mega.png works
#                      too), drawn only with the setting "Mega fusion sprite:
#                      Fusion sprite"; else it is striped
# A sprite picked for the Pokémon on Summary > Pokédex > Sprites (KIF's list:
# this fusion, swapped, line pairs) beats both, drawn with the Mega aura.
# KIF's Import Sprites puts such files there (see the end of this file).
#===============================================================================
module Megas
  PLAYER_DIR = "Graphics/CustomBattlers/Megas" unless defined?(PLAYER_DIR)

  # Path to a file in the mod's Graphics folder the game can load, or nil
  # (relative to the game folder when the mod is inside it)
  def self.graphic(dir, name)
    full = File.join(ROOT, "Graphics", dir, name.to_s)
    return nil if !File.exist?(full + ".png")
    here = Dir.pwd.tr("\\", "/") + "/"
    full = full.tr("\\", "/")
    return full.start_with?(here) ? full[here.length..-1] : full
  end

  # The player's own file for a Mega (id) or Mega fusion ("head.body"), or nil
  def self.player_sprite(name)
    return ["#{PLAYER_DIR}/#{name}.png", "#{PLAYER_DIR}/#{name}.mega.png"].find { |p| File.exist?(p) }
  end

  # A sprite was picked for this fusion on its Sprites page (and is still on)
  def self.picked?(pkmn)
    ps = pkmn.pif_sprite
    return false if !ps || !pkmn.instance_variable_get(:@megas_sprite_pick)
    # Random Sprites Off: KIF draws another species' pick only with its own mark
    return false if !$PokemonSystem.random_sprites && ps.species != pkmn.species && !pkmn.kif_ls_pick
    return true
  end

  def self.sprite_path(id); player_sprite(id) || graphic("Battlers", id); end

  # The player's "<head>.<body>.png" for this Mega fusion while the setting is
  # on, or nil
  def self.fusion_sprite_path(pkmn)
    return nil if !fusion_sprite?
    halves = fusion_halves(pkmn)
    return nil if halves.length < 2
    return player_sprite(halves.map { |sp| GameData::Species.get(sp).id_number }.join("."))
  end

  # A shiny Mega's hue. Not PIF's shiftAllColors: that saves its result as the
  # base species' shiny file (Graphics/Battlers/Shiny/<dex>/<dex>.png), which
  # every normal shiny of the species then shows. Species with colour rules
  # (text, not a number) get PIF's plain hue method instead.
  def self.shiny_hue(pkmn)
    dex = pkmn.id_number
    off = GameData::Species.calculateShinyHueOffset(dex, pkmn.body_shiny, pkmn.head_shiny)
    return off if off.is_a?(Numeric)
    body = pkmn.isFusion? ? getBodyID(dex) : dex   # a Mega fusion's striped sprite
    head = pkmn.isFusion? ? getHeadID(dex, body) : dex
    return GameData::Species.calculateShinyHueOffsetDefaultMethod(body, head, dex, pkmn.body_shiny, pkmn.head_shiny).to_i
  end

  # KIF's shiny engine when it draws this Pokémon, else PIF's hue
  def self.make_shiny!(bmp, pkmn)
    kif = defined?(KIF::Shiny) && KIF::Shiny.kif_render?(pkmn)
    KIF::Shiny.privatize(bmp) if defined?(KIF::Shiny)
    bmp.shiftColors(shiny_hue(pkmn)) if !kif || KIF::Shiny.decide(pkmn)[0]
    KIF::Shiny.colorize!(bmp, pkmn, :sprite, true) if kif
    return bmp
  end

  # A sprite file drawn as is (a player's own or the mod's)
  def self.file_bitmap(path, pkmn, make_shiny)
    bmp = AnimatedBitmap.new(path)   # 192px file (ER 64px at 3x, like PIF) drawn as is
    make_shiny!(bmp, pkmn) if make_shiny && pkmn.shiny?
    return bmp
  end

  # Where KIF's Import Sprites puts a Mega's file, or nil = not one of ours
  #   CHARIZARD_MEGA_X.png  a Mega's id
  #   6.9.mega.png          a Mega fusion's "head.body" (the ".mega" tells it from
  #                         a normal 6.9 fusion sprite, which stays where it goes)
  def self.import_destination(path)
    name = File.basename(path.to_s)
    return nil if name !~ /\A(.+?)(\.mega)?\.png\z/i
    stem, fusion = $1, $2
    if fusion
      return nil if stem !~ /\A(\d+)\.(\d+)\z/
      mega = [$1, $2].any? { |n| (by_base.key?(GameData::Species.get(n.to_i).id) rescue false) }
      return mega ? "#{PLAYER_DIR}/#{stem}.png" : nil
    end
    id = DATA.keys.find { |k| k.to_s.casecmp?(stem) }
    return id ? "#{PLAYER_DIR}/#{id}.png" : nil
  end
end

# Import Sprites: a Mega's file goes to the player's Megas folder
if defined?(KIF::SpriteImport) && KIF::SpriteImport.respond_to?(:game_destination)
  class << KIF::SpriteImport
    alias megas_game_destination game_destination unless method_defined?(:megas_game_destination)
    def game_destination(path)
      return Megas.import_destination(path) || megas_game_destination(path)
    end
  end
end

module GameData
  class Species
    class << self
      alias megas_sprite_bitmap_from_pokemon sprite_bitmap_from_pokemon unless method_defined?(:megas_sprite_bitmap_from_pokemon)
      def sprite_bitmap_from_pokemon(pkmn, *args)
        id = pkmn && !pkmn.egg? && Megas.current(pkmn)
        make_shiny = args[2] != false   # 4th argument (KIF): false = draw it not shiny
        if id.is_a?(Array)   # Mega fusion: the picked sprite + aura, else the player's file (if the setting is on), else the halves striped, else the fusion sprite + aura
          picked = Megas.picked?(pkmn) && megas_sprite_bitmap_from_pokemon(pkmn, *args)
          return Megas.decorate!(picked) if picked   # nil (no bitmap at all): as with no pick
          own = Megas.fusion_sprite_path(pkmn)
          return Megas.file_bitmap(own, pkmn, make_shiny) if own
          return Megas.striped_fusion(pkmn, id, make_shiny) || Megas.decorate!(megas_sprite_bitmap_from_pokemon(pkmn, *args))
        end
        path = id && Megas.sprite_path(id)
        return megas_sprite_bitmap_from_pokemon(pkmn, *args) if !path
        return Megas.file_bitmap(path, pkmn, make_shiny)
      end
    end
  end
end

# Summary > Pokédex > Sprites: a pick made for a fusion is drawn while it is
# Mega too (any other change of its sprite drops the mark)
class Pokemon
  alias megas_pif_sprite_set pif_sprite= unless method_defined?(:megas_pif_sprite_set)
  def pif_sprite=(value)
    @megas_sprite_pick = nil
    return megas_pif_sprite_set(value)
  end
end

class PokemonPokedexInfo_Scene
  alias megas_swap_main_sprite swap_main_sprite unless method_defined?(:megas_swap_main_sprite)
  def swap_main_sprite(*args)
    ret = megas_swap_main_sprite(*args)
    @pokemon.instance_variable_set(:@megas_sprite_pick, true) if @pokemon && @pokemon.isFusion? && @pokemon.pif_sprite
    return ret
  end

  # Use on the sprite it already shows: PIF only says so, but for a fusion
  # that is a pick too (its normal sprite instead of the stripes)
  alias megas_select_species_sprite select_species_sprite unless method_defined?(:megas_select_species_sprite)
  def select_species_sprite(*args)
    main = @pokemon && @pokemon.isFusion? && @available && @available.length > 1 && is_main_sprite
    ret = megas_select_species_sprite(*args)
    if main
      @pokemon.pif_sprite ||= @selected_pif_sprite   # Random Sprites Off: it shows the species' sprite, this one
      @pokemon.instance_variable_set(:@megas_sprite_pick, true)
    end
    return ret
  end
end

# Stone icons (Graphics/Items in the mod folder)
module GameData
  class Item
    class << self
      alias megas_icon_filename icon_filename unless method_defined?(:megas_icon_filename)
      def icon_filename(item)
        data = item && try_get(item)
        return megas_icon_filename(item) if !data || !Megas.stone_species.key?(data.id)   # stones only: no disk check per item
        path = Megas.graphic("Items", data.id)
        path ||= Megas.graphic("Items", "MEGASTONE") if data.instance_variable_get(:@megas_own)   # a stone with no icon of its own
        return path || megas_icon_filename(item)
      end
    end
  end
end
