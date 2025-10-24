class Users::Invite < ApplicationService
  def initialize(user:, organisation:, wait_time: 0.minutes)
    @user = user
    @organisation = organisation
    @wait_time = wait_time
  end

  attr_reader :user, :organisation, :wait_time

  def call
    mailer_class.user_membership_created_notification(user, organisation).deliver_later(wait: wait_time)
  end

  private

  def mailer_class
    organisation.is_a?(School) ? School::UserMailer : Provider::UserMailer
  end
end
