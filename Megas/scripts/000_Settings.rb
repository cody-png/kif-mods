#===============================================================================
# Settings (Options > Modules > Mod Settings > Megas). Cody's design:
#   Mega mode:       Once per battle (default) / Permanent (one per party) /
#                    Permanent+ (every holder)
#   Primal trigger:  Auto (on switch-in) / Manual (the Mega button)
#   Mega fusion stats: Full (default; each Mega half adds its whole boost,
#                    Cody 2026-10-26) / Split (PIF's 2/3 + 1/3 share)
# Trainers follow the same rules as the player.
#===============================================================================
module Megas
  CATEGORY       = "Megas"             unless defined?(CATEGORY)
  SETTING_MODE   = :megas_mode         unless defined?(SETTING_MODE)     # 0 Once per battle, 1 Permanent, 2 Permanent+
  SETTING_PRIMAL = :megas_primal       unless defined?(SETTING_PRIMAL)   # 0 Auto, 1 Manual
  SETTING_FUSION = :megas_fusion_stats unless defined?(SETTING_FUSION)   # 0 Full, 1 Split
  OLD_LIMIT      = :megas_perm_limit   unless defined?(OLD_LIMIT)        # 0.4.0's Permanent limit (1 = No limit)

  def self.setting(key)
    v = ::ModSettingsMenu.get(key) if defined?(::ModSettingsMenu)
    return v.is_a?(Integer) ? v : 0
  rescue StandardError
    return 0
  end

  def self.permanent?;     setting(SETTING_MODE) >= 1;   end
  def self.one_per_party?; setting(SETTING_MODE) == 1;   end
  def self.manual_primal?; setting(SETTING_PRIMAL) == 1; end
  def self.full_boost?;    setting(SETTING_FUSION) == 0; end

  def self.register_settings
    resync = proc { |_v| Megas.sync($Trainer.party) if $Trainer }   # Mega-ness of the party follows the mode
    enum = lambda do |key, name, values, desc, on_change = nil|
      ::ModSettingsMenu.register(key, :name => name, :type => :enum, :values => values, :default => 0,
                                      :description => desc, :category => CATEGORY, :on_change => on_change)
    end
    enum.call(SETTING_MODE, "Mega mode", ["Once per battle", "Permanent", "Permanent+"],
      "Once per battle: use the Mega button. Permanent: one party member stays Mega. Permanent+: every stone holder stays Mega.", resync)
    enum.call(SETTING_PRIMAL, "Primal trigger", ["Auto", "Manual"],
      "Auto: Primal Pokemon revert when sent out. Manual: use the Mega button.")
    restat = proc do |_v|   # cached fusion data and the party's stats follow the new rule
      KIF::Perf.bump_token if defined?(KIF::Perf) && KIF::Perf.respond_to?(:bump_token)
      $Trainer.party.each { |pk| pk.calc_stats if pk && !pk.egg? } if $Trainer
    end
    enum.call(SETTING_FUSION, "Mega fusion stats", ["Full", "Split"],
      "Full: each Mega half adds its whole Mega boost to a fusion. Split: the boost is shared like other fusion stats.", restat)
    migrate_limit
  end

  # 0.4.0 had Permanent + "No limit" as two settings; that is Permanent+ now
  def self.migrate_limit
    return if !defined?(::KIF::ModSettings) || !::KIF::ModSettings.respond_to?(:values)
    v = ::KIF::ModSettings.values
    return if !v.has_key?(OLD_LIMIT)
    v[SETTING_MODE] = 2 if v.delete(OLD_LIMIT) == 1 && v[SETTING_MODE] == 1
    ::KIF::ModSettings.write
  rescue StandardError
  end
end

if defined?(::ModSettingsMenu) && ::ModSettingsMenu.respond_to?(:register)
  Megas.register_settings
else
  $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
  $MOD_SETTINGS_PENDING_REGISTRATIONS << proc { Megas.register_settings }
end
