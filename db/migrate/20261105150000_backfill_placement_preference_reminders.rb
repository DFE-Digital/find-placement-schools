# Records reminders sent under the old daily schedule so users who already had
# three are not emailed again. Runs at deploy, when the old schedule stops.
class BackfillPlacementPreferenceReminders < ActiveRecord::Migration[8.1]
  def up
    PlacementPreferenceReminder.reset_column_information
    Users::PlacementPreferences::BackfillReminders.call
  end

  def down
    # Backfilled rows are indistinguishable from real ones; nothing to undo.
  end
end
