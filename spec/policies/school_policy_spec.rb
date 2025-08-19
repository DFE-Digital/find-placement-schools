require "rails_helper"

RSpec.describe SchoolPolicy do
  subject(:school_policy) { described_class }

  let(:school) { create(:school) }
  let(:user) { create(:user, organisations:, selected_organisation:) }
  let(:selected_organisation) { nil }
  let(:organisations) { [ school ] }

  permissions :show? do
    context "when the selected organisation is not the school record" do
      let(:another_school) { create(:school) }
      let(:organisations) { [ another_school ] }
      let(:selected_organisation) { another_school }

      it "denies access" do
        expect(school_policy).not_to permit(user, school)
      end
    end

    context "when the selected organisation is the school record" do
      let(:selected_organisation) { school }

      it "permits access" do
        expect(school_policy).to permit(user, school)
      end
    end

    context "when the selected organisation is a provider" do
      let(:provider) { create(:provider) }
      let(:selected_organisation) { provider }
      let(:organisations) { [ provider ] }

      it "permits access" do
        expect(school_policy).to permit(user, school)
      end
    end
  end
end
