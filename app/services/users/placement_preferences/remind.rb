class Users::PlacementPreferences::Remind < ApplicationService
  # Each user is reminded at most this many times per school and academic year.
  # Reminders are recorded in PlacementPreferenceReminder, so signing in again
  # does not reset the count.
  MAX_REMINDERS = 3

  # Users who signed in more recently than this are not reminded yet.
  SIGN_IN_GRACE_PERIOD = 2.weeks

  # Guards against a user being reminded twice in quick succession, for
  # example if the job is run again by hand on the same day.
  MINIMUM_TIME_BETWEEN_REMINDERS = 3.weeks

  def call
    wait_time = 0.minutes
    eligible_memberships.preload(:user, :organisation).find_in_batches(batch_size: 100) do |batch|
      batch.each { |membership| remind(membership, wait: wait_time) }

      wait_time += 1.minute
    end
  end

  private

  # Locks the membership and rechecks eligibility so overlapping runs cannot
  # exceed the cap. Solid Queue shares the primary database, so the reminder
  # record and the enqueued email are committed (or rolled back) together.
  def remind(membership, wait:)
    UserMembership.transaction do
      UserMembership.lock.find(membership.id)
      next unless eligible_memberships.exists?(membership.id)

      PlacementPreferenceReminder.create!(
        user: membership.user,
        organisation: membership.organisation,
        academic_year:,
      )

      School::UserMailer.placement_preferences_reminder_notification(
        membership.user,
        membership.organisation,
        academic_year,
      ).deliver_later(wait:)
    end
  end

  def academic_year
    @academic_year ||= AcademicYear.next
  end

  def idle_schools
    School.without_preference_for(academic_year)
  end

  # One membership per user and school, so a user belonging to several schools
  # is reminded about each school that is missing a preference.
  def eligible_memberships
    UserMembership
      .joins(:user)
      .where(organisation_id: idle_schools.select(:id))
      .where(users: { last_signed_in_at: ..SIGN_IN_GRACE_PERIOD.ago })
      .where("(#{previous_reminders.select('COUNT(*)').to_sql}) < ?", MAX_REMINDERS)
      .where("NOT EXISTS (#{previous_reminders.where(created_at: MINIMUM_TIME_BETWEEN_REMINDERS.ago..).to_sql})")
  end

  # Reminders already sent for the membership being considered, correlated to
  # the outer user_memberships row.
  def previous_reminders
    PlacementPreferenceReminder
      .where(academic_year:)
      .where("placement_preference_reminders.user_id = user_memberships.user_id")
      .where("placement_preference_reminders.organisation_id = user_memberships.organisation_id")
  end
end
