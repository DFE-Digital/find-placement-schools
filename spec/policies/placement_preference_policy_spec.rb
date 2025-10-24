require "rails_helper"

RSpec.describe PlacementPreferencePolicy do
  subject(:placement_preference_policy) { described_class }

  let(:user) { create(:user, selected_organisation:) }

  permissions :new? do
    let(:placement_preference) { PlacementPreference.new }

    context "when the user does not have a selected organisation" do
      let(:selected_organisation) { nil }

      it "denies access" do
        expect(placement_preference_policy).not_to permit(user, placement_preference)
      end
    end

    context "when the user has a selected organisation" do
      let(:selected_organisation) { create(:school) }

      it "permits access" do
        expect(placement_preference_policy).to permit(user, placement_preference)
      end
    end
  end

  permissions :edit? do
    context "when the user's selected organisation is not the placement preference organisation" do
      let(:placement_preference) { create(:placement_preference) }
      let(:selected_organisation) { create(:school) }

      it "denies access" do
        expect(placement_preference_policy).not_to permit(user, placement_preference)
      end
    end

    context "when the user's selected organisation is the placement preference organisation" do
      let(:placement_preference) { create(:placement_preference, organisation: selected_organisation) }
      let(:selected_organisation) { create(:school) }

      it "permits access" do
        expect(placement_preference_policy).to permit(user, placement_preference)
      end
    end
  end
end
