class Users::SendSurvey < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  def call
    return if user.survey_sent_at.present?

    mailer_class.user_feedback_request_notification(user).deliver_later
    user.update!(survey_sent_at: Time.current)
  end

  private

  attr_reader :user, :organisation

  def mailer_class
    organisation.is_a?(School) ? School::UserMailer : Provider::UserMailer
  end
end
