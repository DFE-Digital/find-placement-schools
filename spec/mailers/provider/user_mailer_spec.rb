require "rails_helper"

RSpec.describe Provider::UserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:user) }
    let(:organisation) { create(:school) }

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email_address)
      expect(invite_email.subject).to eq("Invitation to join Find placement schools")
      expect(invite_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        You have been invited to join the Find placement schools service for #{organisation.name}.

        Use this service to find placement schools for your trainee teachers. You can find information about:

        - schools' ability to host placements for trainee teachers in academic years 2025/26 and 2026/27

        - previous school engagement in initial teacher training

        Please note that:

        - you cannot contact schools via this service

        - information about schools' ability to host placements is indicative and does not reflect the number of placements a school can offer.

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
end
