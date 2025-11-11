require "rails_helper"

RSpec.describe School::UserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:user) }
    let(:organisation) { create(:school) }

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email_address)
      expect(invite_email.subject).to eq("Invitation to join Find placement schools")
      expect(invite_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        You are invited to sign in to the Find placement schools service for #{organisation.name}.

        Please sign in this week to register your school's ability to offer school placements for trainee teachers. If you are not the right staff member to do this, sign in to the service now to add the appropriate colleague(s) as a user.

        This is not a commitment to offer school placements but it helps teacher training providers know whether to contact you and helps the Department for Education understand school capacity to support teacher training.

        This service is being trialled by the Department for Education with schools and teacher training providers in England.

        [Sign in to Find placement schools](http://localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        If you do not have DfE Sign-in, create an account. You can then return to this email to access the service.

        If you need help or have feedback for us, contact [find.placementschools@education.gov.uk](mailto:find.placementschools@education.gov.uk).

        Regards

        Find placement schools team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(invite_email.subject).to eq("Invitation to join Find placement schools")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(invite_email.subject).to eq("[STAGING] Invitation to join Find placement schools")
      end
    end
  end

  describe "#user_membership_destroyed_notification" do
    subject(:removal_email) { described_class.user_membership_destroyed_notification(user, organisation) }

    let(:user) { create(:user) }
    let(:organisation) { create(:school) }

    it "sends expected message to user" do
      expect(removal_email.to).to contain_exactly user.email_address
      expect(removal_email.subject).to eq "You have been removed from Find placement schools"
      expect(removal_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        You have been removed from the Find placement schools service for #{organisation.name}.

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [find.placementschools@education.gov.uk](mailto:find.placementschools@education.gov.uk).

        Regards

        Find placement schools team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(removal_email.subject).to eq("You have been removed from Find placement schools")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(removal_email.subject).to eq("[STAGING] You have been removed from Find placement schools")
      end
    end
  end

  describe "#user_membership_sign_in_reminder_notification" do
    subject(:user_membership_sign_in_reminder_notification) do
      described_class.user_membership_sign_in_reminder_notification(user)
    end

    let(:user) { create(:user) }

    it "sends a sign in reminder to the user" do
      expect(user_membership_sign_in_reminder_notification.to).to contain_exactly(user.email_address)
      expect(user_membership_sign_in_reminder_notification.subject).to eq(
        "Reminder: Record Your School’s interest in hosting ITT placements"
      )
      expect(user_membership_sign_in_reminder_notification.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        A couple of weeks ago, we let you know about the Department for Education’s new [Find Placement Schools](http://localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email) service - designed to make it quicker and easier for you to record your school’s ability to host trainee teachers on placements.

        We’ve noticed your school hasn’t yet signed in. To get started, your DfE Sign-in approver should have received an on-boarding email and can log in and add other users if needed.

        ## Please take a moment to:

        1. Sign in using your DfE Sign-in credentials

        2. Record your preferences for hosting placements

        3. Add any extra details you’d like to share (e.g. phase, subject)

        Sharing your preferences makes it easier for ITT providers to connect with your school if you’re interested in hosting placements - or lets them know you’re not able to host placements at the moment.

        You can update your information at any time, and we’ll send reminders to help keep it current.

        If you have any questions or feedback, please contact us at [find.placementschools@education.gov.uk](mailto:find.placementschools@education.gov.uk).

        Many thanks,

        Find placement schools team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(user_membership_sign_in_reminder_notification.subject).to eq(
          "Reminder: Record Your School’s interest in hosting ITT placements"
        )
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(user_membership_sign_in_reminder_notification.subject).to eq(
          "[STAGING] Reminder: Record Your School’s interest in hosting ITT placements"
        )
      end
    end
  end

  describe "placement_preferences_reminder_notification" do
    subject(:placement_preferences_reminder_notification) do
      described_class.placement_preferences_reminder_notification(user)
    end

    let(:user) { create(:user) }

    it "sends a sign in reminder to the user" do
      expect(placement_preferences_reminder_notification.to).to contain_exactly(user.email_address)
      expect(placement_preferences_reminder_notification.subject).to eq(
        "Reminder: Record Your School’s interest in hosting ITT placements"
      )
      expect(placement_preferences_reminder_notification.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        Thank you for signing in to the Department for Education’s new [Find Placement Schools](http://localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email) service.

        We’ve noticed your school hasn’t yet recorded its ability to host trainee teachers on placements. Sharing your preferences helps ITT providers connect with your school if you're interested in hosting placements - and lets them know if you're not currently able to.

        ## To complete your expression of interest:

        1. Sign in using your DfE Sign-in credentials

        2. Record your preferences for hosting placements

        3. Add any extra details you’d like to share (e.g. phase, subject)

        You can update your information at any time, and we’ll send reminders to help keep it current.

        If you have any questions or feedback, please contact us at [find.placementschools@education.gov.uk](mailto:find.placementschools@education.gov.uk).

        Many thanks,

        Find placement schools team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(placement_preferences_reminder_notification.subject).to eq(
          "Reminder: Record Your School’s interest in hosting ITT placements"
        )
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(placement_preferences_reminder_notification.subject).to eq(
          "[STAGING] Reminder: Record Your School’s interest in hosting ITT placements"
        )
      end
    end
  end

  describe "placement_preference_completion_notification" do
    subject(:placement_preference_completion_notification) do
      described_class.placement_preference_completion_notification(user)
    end

    let(:user) { create(:user) }

    it "sends a sign in reminder to the user" do
      expect(placement_preference_completion_notification.to).to contain_exactly(user.email_address)
      expect(placement_preference_completion_notification.subject).to eq(
        "We’d Appreciate Your Feedback – Just 1 Minute"
      )
      expect(placement_preference_completion_notification.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        Thank you for using the [Find Placement Schools](http://localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email) service.

        To help us continue improving, we’d be grateful if you could take a moment to complete a very short feedback form. It should take less than one minute to complete.

        #{ENV.fetch("EOI_SURVEY_LINK", "")}

        We really appreciate your feedback – it helps us make the service work better for you.

        Regards,

        Find placement schools team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(placement_preference_completion_notification.subject).to eq(
          "We’d Appreciate Your Feedback – Just 1 Minute"
        )
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(placement_preference_completion_notification.subject).to eq(
          "[STAGING] We’d Appreciate Your Feedback – Just 1 Minute"
        )
      end
    end
  end
end
