require "rails_helper"

RSpec.describe AddHostingInterestWizard::AppetiteStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(appetite: nil) }
  end

  describe "validations" do
    let(:appetites) { %w[actively_looking interested not_open] }

    it {
      expect(step).to validate_inclusion_of(:appetite).in_array(
        appetites,
      )
    }
  end

  describe "#appetite_options" do
    subject(:appetite_options) { step.appetite_options }

    it "returns struct objects for each appetite" do
      actively_looking = appetite_options[0]
      interested = appetite_options[1]
      not_open = appetite_options[2]

      expect(actively_looking.value).to eq("actively_looking")
      expect(actively_looking.name).to eq("Yes")

      expect(interested.value).to eq("interested")
      expect(interested.name).to eq("Maybe")

      expect(not_open.value).to eq("not_open")
      expect(not_open.name).to eq("No")
    end
  end

  describe "#placement_appetites" do
    subject(:placement_appetites) { step.placement_appetites }

    let(:appetites) { %w[actively_looking interested not_open] }

    it "returns the keys of the appetites" do
      expect(placement_appetites).to match_array(appetites)
    end
  end
end
