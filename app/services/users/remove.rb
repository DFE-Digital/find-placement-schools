class Users::Remove < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation

  def call
    user_membership.transaction do
      user_membership.destroy!
      mailer_class.user_membership_destroyed_notification(user, organisation).deliver_later
    end
  end

  private

  def user_membership
    @user_membership ||= user.user_memberships.find_by!(organisation:)
  end

  def mailer_class
    organisation.is_a?(School) ? School::UserMailer : Provider::UserMailer
  end
end
