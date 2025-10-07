require "rails_helper"

RSpec.describe School::UserMailer, type: :mailer do
  describe "#placement_preferences_notification" do
    let!(:user) { create(:user, email_address: "test@sample.com", first_name: "Joe") }
    subject(:placement_preferences_notification) { described_class.placement_preferences_notification(user) }

    let!(:current_year) { create(:academic_year, :current) }

    let!(:eligible_school) { create(:school, name: "Shelbyville School") }

    let!(:user_membership_to_eligible_school) do
      create(:user_membership, user: user, organisation: eligible_school)
    end

    let!(:ineligible_school) { create(:school, name: "Springfield High") }
    let!(:ineligible_placement_preference) do
      create(:placement_preference, organisation: ineligible_school, academic_year: current_year, created_by: create(:user))
    end

    it "sends the placement preferences notification email" do
      expect(placement_preferences_notification.to).to contain_exactly("test@sample.com")
      expect(placement_preferences_notification.subject).to eq("[DEVELOPMENT] Please update your schools placement preferences")
      expect(placement_preferences_notification.body.to_s.squish).to eq(<<~EMAIL.squish)
        Joe,

        The following schools:
        Shelbyville School

        Have no placement preferences. Please update their placement preferences.

        This notification will be sent once a month.
      EMAIL
    end
  end

  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:user) }
    let(:organisation) { create(:school) }

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email_address)
      expect(invite_email.subject).to eq("[DEVELOPMENT] Invitation to join Find placement schools")
      expect(invite_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        You have been invited to join the Find placement schools service for #{organisation.name}.

        Use this service to register your school’s ability to offer school placements for trainee teachers.

        This helps teacher training providers know whether to contact you and helps the Department for Education understand school capacity to support teacher training.

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
      expect(removal_email.subject).to eq "[DEVELOPMENT] You have been removed from Find placement schools"
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
end
