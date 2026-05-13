require "rails_helper"

RSpec.describe Admin::UserMailer, type: :mailer do
  describe "#user_created_notification" do
    subject(:invite_email) { described_class.user_created_notification(user) }

    let(:user) { create(:user, :admin) }
    let(:slack_url) { "https://slack.example.com/support" }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("SUPPORT_SLACK_URL", "").and_return(slack_url)
    end

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email_address)
      expect(invite_email.subject).to eq("Invitation to join Find placement schools")
      expect(invite_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        You have been invited to join the Find placement schools service

        # Sign in to the support site

        If you have a DfE Sign-in account, you can use it to sign in:

        [http://localhost/sign-in?utm_campaign=admin&utm_medium=notification&utm_source=email](http://localhost/sign-in?utm_campaign=admin&utm_medium=notification&utm_source=email)

        If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

        After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://localhost/sign-in?utm_campaign=admin&utm_medium=notification&utm_source=email).

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the service team.

        Regards

        Find placement schools team
      EMAIL
    end
  end
end
