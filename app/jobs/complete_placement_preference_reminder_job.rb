# Scheduled to run daily on the 1st-3rd of each month (see config/recurring.yml),
# but only sends reminders on the 1st, or the following Monday when the 1st falls
# on a weekend.
class CompletePlacementPreferenceReminderJob < ApplicationJob
  queue_as :default

  def self.send_day?(date)
    first_of_month = date.beginning_of_month
    send_day = first_of_month.on_weekend? ? first_of_month.next_occurring(:monday) : first_of_month
    date == send_day
  end

  def perform
    return unless self.class.send_day?(Date.current)

    Users::PlacementPreferences::Remind.call
  end
end
