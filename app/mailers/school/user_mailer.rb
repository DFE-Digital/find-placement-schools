class School::UserMailer < ApplicationMailer
  def user_membership_created_notification(user, organisation)
    notify_email to: user.email_address,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   academic_year_name: AcademicYear.current.decorate.name,
                   support_email:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school"),
                 )
  end

  def user_membership_destroyed_notification(user, organisation)
    notify_email to: user.email_address,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   support_email:,
                 )
  end

  def user_membership_sign_in_reminder_notification(user)
    notify_email to: user.email_address,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   service_name:,
                   support_email:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")
                 )
  end

  def placement_preferences_reminder_notification(user)
    notify_email to: user.email_address,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   service_name:,
                   support_email:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")
                 )
  end

  def user_feedback_request_notification(user)
    notify_email to: user.email_address,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   service_name:,
                   support_email:,
                   survey_link: ENV.fetch("EOI_SURVEY_LINK", ""),
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")
                 )
  end

  private

  def support_email
    t("layouts.footer.support_email")
  end

  def service_name
    t("service.name")
  end
end
