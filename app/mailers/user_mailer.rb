class UserMailer < ApplicationMailer
  def placement_preferences_notification(user)
    @user = User.find(user.id)
    notify_email to: @user.email_address,
                 subject: t(".subject"),
                 body: I18n.t(
                 "user_mailer.placement_preferences_notification.body",
                    user_name: @user.first_name,
                    school_names: School
                    .without_preference_for(AcademicYear.current)
                    .joins(:user_memberships)
                    .where(user_memberships: { user_id: user.id })
                    .distinct
                    .pluck(:name)
                    .join(", ")
                  )
  end
end
