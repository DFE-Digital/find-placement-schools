class AddProviderPlacementHelpBroadcastFeatureFlag < ActiveRecord::Migration[8.0]
  def up
    Flipper.add(:provider_help_find_placements_broadcast)
  end

  def down
    Flipper.remove(:provider_help_find_placements_broadcast)
  end
end
