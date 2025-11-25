class Users::Invite::Remind < ApplicationService
    def call
      wait_time = 0.minutes
      idle_users.find_in_batches(batch_size: 100) do |batch|
        batch.each do |user|
          School::UserMailer.user_membership_sign_in_reminder_notification(user).deliver_later(wait: wait_time)
        end

        wait_time += 1.minute
      end
    end


    private

    def idle_users
      first_reminder_users.or(second_reminder_users.or(third_reminder_users))
    end

    def first_reminder_cadence
      2.weeks.ago
    end

    def first_reminder_users
      User.where(last_signed_in_at: nil)
        .where(
          "created_at > ? AND created_at < ?",
          first_reminder_cadence.beginning_of_day,
          first_reminder_cadence.at_end_of_day,
        )
    end

    def second_reminder_cadence
      first_reminder_cadence - 1.month
    end

      def second_reminder_users
        User.where(last_signed_in_at: nil)
        .where(
          "created_at > ? AND created_at < ?",
          second_reminder_cadence.beginning_of_day,
          second_reminder_cadence.at_end_of_day,
        )
      end

    def third_reminder_cadence
      second_reminder_cadence - 1.month
    end

    def third_reminder_users
      User.where(last_signed_in_at: nil)
        .where(
          "created_at > ? AND created_at < ?",
          third_reminder_cadence.beginning_of_day,
          third_reminder_cadence.at_end_of_day,
        )
    end
end
