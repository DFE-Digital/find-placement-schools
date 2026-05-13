class Admin::UserMailer < ApplicationMailer
  def user_created_notification(user)
    notify_email to: user.email_address,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   service_name:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "admin"),
                 )
  end

  private

  def service_name
    t("service.name")
  end
end
