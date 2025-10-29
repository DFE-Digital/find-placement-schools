class UserSignInReminderJob < ApplicationJob
  queue_as :default

  def perform
    Users::Invite::Remind.call
  end
end
