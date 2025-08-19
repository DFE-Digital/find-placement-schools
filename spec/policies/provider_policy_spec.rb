require "rails_helper"

RSpec.describe ProviderPolicy do
  subject(:provider_policy) { described_class }

  let(:provider) { create(:provider) }
  let(:user) { create(:user, organisations:, selected_organisation:) }
  let(:selected_organisation) { nil }
  let(:organisations) { [provider] }

  permissions :show? do
    context "when the selected organisation is not the provider record" do
      context "when the selected organisation is a provider record" do
        let(:selected_organisation) { create(:provider) }

        it "denies access" do
          expect(provider_policy).not_to permit(user, provider)
        end
      end

      context "when the selected organisation is a school record" do
        let(:selected_organisation) { create(:school) }

        it "denies access" do
          expect(provider_policy).not_to permit(user, provider)
        end
      end
    end

    context "when the selected organisation is the provider record" do
      let(:selected_organisation) { provider }

      it "permits access" do
        expect(provider_policy).to permit(user, provider)
      end
    end
  end
end
