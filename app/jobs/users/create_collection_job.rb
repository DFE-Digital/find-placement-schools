class Users::CreateCollectionJob < ApplicationJob
  queue_as :default

  def perform(user_details:)
    wait_time = 0.minutes

    user_details.each_slice(100) do |batch|
      batch.each do |user_detail|
        organisation = Organisation.find_by(id: user_detail[:organisation_id])
        next if organisation&.users&.find_by(email_address: user_detail[:email_address])

        user = User.find_or_create_by(email_address: user_detail[:email_address]) do |u|
          u.first_name = user_detail[:first_name]
          u.last_name = user_detail[:last_name]
        end

        next unless user.present?

        user.user_memberships.find_or_create_by(organisation:)

        Users::Invite.call(user:, organisation:, wait_time:)
      end

      wait_time += 1.minute
    end
  end
end
