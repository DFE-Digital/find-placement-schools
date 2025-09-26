require "rails_helper"

RSpec.describe PreviousPlacementPolicy do
  subject(:previous_placement_policy) { described_class }

  let(:previous_placement) { PreviousPlacement.new }

  permissions :new?, :edit?, :update? do
    context "when the user does not an admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        expect(previous_placement_policy).not_to permit(user, previous_placement)
      end
    end

    context "when the user has a selected organisation" do
      let(:user) { create(:user, :admin) }

      it "permits access" do
        expect(previous_placement_policy).to permit(user, previous_placement)
      end
    end
  end
end
