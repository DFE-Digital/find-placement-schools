class Schools::UserMailerPreview < ActionMailer::Preview
  def user_membership_sign_in_reminder_notification
    School::UserMailer.user_membership_sign_in_reminder_notification(user, organisation)
  end

  def placement_preferences_reminder_notification
    School::UserMailer.placement_preferences_reminder_notification(user)
  end

  def user_feedback_request_notification
    School::UserMailer.user_feedback_request_notification(user)
  end

  private

  def user
    User.new(first_name: "Joe", last_name: "Bloggs", email_address: "joe_bloggs@example.com")
  end

  def organisation
    Organisation.new(name: "Hogwarts School of Witchcraft and Wizardry", urn: "123456", type: "School")
  end
end
