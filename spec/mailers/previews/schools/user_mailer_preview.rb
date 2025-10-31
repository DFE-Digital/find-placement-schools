class Schools::UserMailerPreview < ActionMailer::Preview
  def user_membership_sign_in_reminder_notification
    School::UserMailer.user_membership_sign_in_reminder_notification(user)
  end

  def placement_preferences_reminder_notification
    School::UserMailer.placement_preferences_reminder_notification(user)
  end

  def placement_preference_completion_notification
    School::UserMailer.placement_preference_completion_notification(user)
  end

  private

  def user
    User.new(first_name: "Joe", last_name: "Bloggs", email_address: "joe_bloggs@example.com")
  end
end
