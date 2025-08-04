require "rails_helper"

RSpec.describe AddHostingInterestWizard::PhaseStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(phases: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phases) }
  end

  describe "#phase_options" do
    subject(:phase_options) { step.phase_options }

    it "returns the phase options primary, secondary and send" do
      expect(phase_options).to contain_exactly("primary", "secondary", "send")
    end
  end

  describe "#phases_for_selection" do
    subject(:phases_for_selection) { step.phases_for_selection }

    it "returns all year groups, expect for mixed year group" do
      expect(phases_for_selection).to eq(
        [
          OpenStruct.new(value: "primary", name: "Primary", description: "3 to 11 years"),
          OpenStruct.new(value: "secondary", name: "Secondary", description: "11 to 19 years"),
          OpenStruct.new(
            value: "send",
            name: "Special educational needs and disabilities (SEND) specific",
            description: "You will be able to select key stages"
          )
        ],
      )
    end
  end

  describe "#phases" do
    subject(:phases) { step.phases }

    context "when phases is blank" do
      it "returns an empty array" do
        expect(phases).to eq([])
      end
    end

    context "when the phases attribute contains a blank element" do
      let(:attributes) { { phases: [ "primary", nil ] } }

      it "removes the nil element from the phases attribute" do
        expect(phases).to contain_exactly("primary")
      end
    end

    context "when the phases attribute contains no blank elements" do
      let(:attributes) { { phases: %w[primary secondary] } }

      it "returns the phases attribute unchanged" do
        expect(phases).to contain_exactly(
          "primary",
          "secondary",
        )
      end
    end
  end
end
