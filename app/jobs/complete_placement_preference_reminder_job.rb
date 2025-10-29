class CompletePlacementPreferenceReminderJob < ApplicationJob
  queue_as :default

  def perform
    Users::PlacementPreferences::Remind.call
  end
end
