require "rails_helper"

RSpec.describe Users::Remove do
  subject(:remove_user_service) { described_class.call(user:, organisation:) }

  it_behaves_like "a service object" do
    let(:params) { { user: create(:user), organisation: create(:school) } }
  end

  describe "#call" do
    context "when the organisation is a school" do
      let(:user) { create(:user) }
      let(:organisation) { create(:school) }
      let!(:membership) { create(:user_membership, user:, organisation:) }

      it "calls mailer with correct params" do
        expect { remove_user_service }.to have_enqueued_mail(School::UserMailer, :user_membership_destroyed_notification).with(user, organisation)

        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the organisation is a provider" do
      let(:user) { create(:user) }
      let(:organisation) { create(:provider) }
      let!(:membership) { create(:user_membership, user:, organisation:) }

      it "calls mailer with correct params" do
        expect { remove_user_service }.to have_enqueued_mail(Provider::UserMailer, :user_membership_destroyed_notification).with(user, organisation)

        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
