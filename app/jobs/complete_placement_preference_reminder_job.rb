# Scheduled to run daily during the first week of each month (see
# config/recurring.yml), but only sends reminders on the first working day of
# the month: the 1st, or the next day that is neither a weekend nor a bank
# holiday.
class CompletePlacementPreferenceReminderJob < ApplicationJob
  queue_as :default

  def self.send_day?(date)
    date == BankHoliday.next_working_day(date.beginning_of_month)
  end

  def perform
    return unless self.class.send_day?(Date.current)

    Users::PlacementPreferences::Remind.call
  end
end
