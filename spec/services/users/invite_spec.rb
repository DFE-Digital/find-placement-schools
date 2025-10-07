require "rails_helper"

RSpec.describe Users::Invite do
  subject(:user_invite_service) { described_class.call(user:, organisation:) }

  it_behaves_like "a service object" do
    let(:params) { { user: create(:user), organisation: create(:school) } }
  end

  describe "call" do
    describe "when the organisation is a school" do
      let(:user) { create(:user) }
      let(:organisation) { create(:school) }

      it "calls mailer with correct prams" do
        expect { user_invite_service }.to have_enqueued_mail(School::UserMailer, :user_membership_created_notification).with(user, organisation)
      end
    end

    describe "when the organisation is a provider" do
      let(:user) { create(:user) }
      let(:organisation) { create(:provider) }

      it "calls mailer with correct prams" do
        expect { user_invite_service }.to have_enqueued_mail(Provider::UserMailer, :user_membership_created_notification).with(user, organisation)
      end
    end
  end
end
