class Users::Invite < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation, :service

  def call
    mailer_class.user_membership_created_notification(user, organisation).deliver_later
  end

  private

  def mailer_class
    organisation.is_a?(School) ? School::UserMailer : Provider::UserMailer
  end
end
