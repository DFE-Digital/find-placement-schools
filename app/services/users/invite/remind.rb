class Users::Invite::Remind < ApplicationService
    def call
      wait_time = 0.minutes
      memberships_scope.find_in_batches(batch_size: 100) do |batch|
        batch.each do |membership|
          School::UserMailer.user_membership_sign_in_reminder_notification(membership.user, membership.organisation)
                            .deliver_later(wait: wait_time)
        end

        wait_time += 1.minute
      end
    end


    private

    def memberships_scope
      first_reminder_memberships.or(second_reminder_memberships.or(third_reminder_memberships))
    end

    def first_reminder_cadence
      2.weeks.ago
    end

    def first_reminder_memberships
      idle_memberships.where(
        user: { created_at: first_reminder_cadence.beginning_of_day..first_reminder_cadence.at_end_of_day }
      )
    end

    def second_reminder_cadence
      first_reminder_cadence - 1.month
    end

    def second_reminder_memberships
      idle_memberships.where(
        user: { created_at: second_reminder_cadence.beginning_of_day..second_reminder_cadence.at_end_of_day }
      )
    end

    def third_reminder_cadence
      second_reminder_cadence - 1.month
    end

    def third_reminder_memberships
      idle_memberships.where(
        user: { created_at: third_reminder_cadence.beginning_of_day..third_reminder_cadence.at_end_of_day }
      )
    end

    def idle_schools
      @idle_schools ||= School.includes(:users, :placement_preferences)
        .without_preference_for(AcademicYear.next)
        .where.associated(:users)
    end

    def idle_memberships
      @idle_memberships ||= UserMembership.includes(:user, :organisation)
        .where(organisation_id: idle_schools.select(:id))
        .where(user: { last_signed_in_at: nil })
    end
end
