require "rails_helper"

RSpec.describe UrgentPlacementBroadcastWizard::LocationSearchStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(UrgentPlacementBroadcastWizard)
  end

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(location: nil, radius: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:radius) }

    context "when the radius is a whole number" do
      let(:attributes) { { radius: 5, location: "London" } }

      it { is_expected.to be_valid }
    end

    context "when the radius is not an integer" do
      let(:attributes) { { radius: 1.5, location: "London" } }

      it { is_expected.not_to be_valid }
    end

    context "when the radius is less than 1" do
      let(:attributes) { { radius: 0, location: "London" } }

      it { is_expected.not_to be_valid }
    end
  end
end
