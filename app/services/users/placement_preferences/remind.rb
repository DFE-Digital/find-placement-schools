class Users::PlacementPreferences::Remind < ApplicationService
  def call
    idle_users.find_in_batches do |batch|
      batch.each do |user|
        School::UserMailer.placement_preferences_reminder_notification(user).deliver_later
      end
    end
  end


  private

  def idle_schools
    @idle_schools ||= School.includes(:users, :placement_preferences)
      .without_preference_for(AcademicYear.next)
      .where.associated(:users)
  end

  def idle_school_users
    @idle_school_users ||= User.joins(:organisations).where(organisations: { id: idle_schools.ids })
  end

  def idle_users
    first_reminder_users.or(second_reminder_users.or(third_reminder_users))
  end

  def first_reminder_cadence
    2.weeks.ago
  end

  def first_reminder_users
    idle_school_users
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
    idle_school_users
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
    idle_school_users
      .where(
        "last_signed_in_at > ? AND last_signed_in_at < ?",
        third_reminder_cadence.beginning_of_day,
        third_reminder_cadence.at_end_of_day,
      )
  end
end
