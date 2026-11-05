# One-off backfill (run by a data migration) that records the reminders sent
# by the old daily schedule, so they count towards the three-reminder cap in
# Users::PlacementPreferences::Remind.
#
# The old schedule ran every day at 10:00 UTC and reminded users at schools
# missing a preference for AcademicYear.next whose last sign-in was exactly
# 2 weeks, 2 weeks and 1 month, or 2 weeks and 2 months before the run day.
# Each past run day is replayed against the user's current last sign-in.
#
# Only run days since the start of the current academic year are replayed:
# since then AcademicYear.next has been the year reminders are now about, so a
# school still missing that preference was missing it on every replayed day.
class Users::PlacementPreferences::BackfillReminders < ApplicationService
  OLD_RUN_HOUR = 10

  # Allows for month-end clamping in the old "1 month earlier" arithmetic.
  WINDOW_MARGIN = 7.days

  def initialize(until_date: Date.current)
    @until_date = until_date
  end

  def call
    candidate_memberships.find_each do |membership|
      old_run_days_for(membership).each do |run_on|
        record_reminder(membership, run_on)
      end
    end
  end

  private

  attr_reader :until_date

  def academic_year
    @academic_year ||= AcademicYear.next
  end

  def replay_from
    @replay_from ||= AcademicYear.current.starts_on
  end

  def candidate_memberships
    UserMembership
      .includes(:user)
      .joins(:user)
      .where(organisation_id: School.without_preference_for(academic_year).select(:id))
      .where(users: { last_signed_in_at: (replay_from - 2.weeks - 2.months - WINDOW_MARGIN).beginning_of_day.. })
  end

  def old_run_days_for(membership)
    signed_in_on = membership.user.last_signed_in_at.to_date
    first_day = [ signed_in_on + 2.weeks, replay_from, membership.created_at.to_date ].max
    last_day = [ signed_in_on + 2.weeks + 2.months + WINDOW_MARGIN, until_date ].min

    (first_day..last_day).select { |run_on| old_reminder_days(run_on).include?(signed_in_on) }
  end

  # Mirrors the old first/second/third reminder cadence for a run day.
  def old_reminder_days(run_on)
    first = run_on - 2.weeks
    second = first - 1.month
    third = second - 1.month
    [ first, second, third ]
  end

  def record_reminder(membership, run_on)
    sent_at = run_on.in_time_zone.change(hour: OLD_RUN_HOUR)
    reminders = PlacementPreferenceReminder.where(
      user_id: membership.user_id,
      organisation_id: membership.organisation_id,
      academic_year:,
    )
    return if reminders.where(created_at: sent_at.all_day).exists?

    reminders.create!(created_at: sent_at, updated_at: sent_at)
  end
end
