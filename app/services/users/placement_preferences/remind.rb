class Users::PlacementPreferences::Remind < ApplicationService
  def call
    wait_time = 0.minutes
    idle_memberships.find_in_batches(batch_size: 100) do |batch|
      batch.each do |membership|
        School::UserMailer.placement_preferences_reminder_notification(
          membership.user,
          membership.organisation,
          academic_year,
        ).deliver_later(wait: wait_time)
      end

      wait_time += 1.minute
    end
  end

  private

  def academic_year
    @academic_year ||= AcademicYear.next
  end

  def idle_schools
    @idle_schools ||= School.without_preference_for(academic_year)
  end

  # One membership per user and school, so a user belonging to several schools
  # is reminded about each school that is missing a preference.
  def idle_memberships
    @idle_memberships ||= UserMembership
      .includes(:user, :organisation)
      .joins(:user)
      .where(organisation_id: idle_schools.select(:id))
      .merge(idle_users)
  end

  def idle_users
    first_reminder_users.or(second_reminder_users.or(third_reminder_users))
  end

  def first_reminder_cadence
    2.weeks.ago
  end

  def first_reminder_users
    User
      .where(
        "last_signed_in_at > ? AND last_signed_in_at < ?",
        first_reminder_cadence.beginning_of_day,
        first_reminder_cadence.at_end_of_day,
      )
  end

  def second_reminder_cadence
    first_reminder_cadence - 1.month
  end

  def second_reminder_users
    User
      .where(
        "last_signed_in_at > ? AND last_signed_in_at < ?",
        second_reminder_cadence.beginning_of_day,
        second_reminder_cadence.at_end_of_day,
      )
  end

  def third_reminder_cadence
    second_reminder_cadence - 1.month
  end

  def third_reminder_users
    User
      .where(
        "last_signed_in_at > ? AND last_signed_in_at < ?",
        third_reminder_cadence.beginning_of_day,
        third_reminder_cadence.at_end_of_day,
      )
  end
end
