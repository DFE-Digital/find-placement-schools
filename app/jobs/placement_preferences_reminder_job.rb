class PlacementPreferencesReminderJob < ApplicationJob
  queue_as :mailers

  def perform
    ids = School.users_without_preference_for(AcademicYear.current).pluck(:id)
    ids.each do |id|
      UserMailer.placement_preferences_notification(id).deliver_later
    end
  end
end
