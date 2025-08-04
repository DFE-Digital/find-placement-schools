require "rails_helper"

RSpec.describe AddHostingInterestWizard::KeyStageSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(key_stages: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:key_stages) }
  end

  describe "#key_stages_for_selection" do
    subject(:key_stages_for_selection) { step.key_stages_for_selection }

    it "returns all year groups, expect for mixed year group" do
      expect(key_stages_for_selection).to eq(
        [
          OpenStruct.new(value: "early_years", name: "Early years"),
          OpenStruct.new(value: "key_stage_1", name: "Key stage 1"),
          OpenStruct.new(value: "key_stage_2", name: "Key stage 2"),
          OpenStruct.new(value: "key_stage_3", name: "Key stage 3"),
          OpenStruct.new(value: "key_stage_4", name: "Key stage 4"),
          OpenStruct.new(value: "key_stage_5", name: "Key stage 5")
        ],
      )
    end
  end

  describe "#mixed_key_stage_option" do
    subject(:mixed_key_stage_option) { step.mixed_key_stage_option }

    it "returns the mixed year group" do
      expect(mixed_key_stage_option).to eq(
        OpenStruct.new(value: "mixed_key_stages", name: "Mixed key stages"),
      )
    end
  end

  describe "#key_stages" do
    subject(:key_stages) { step.key_stages }

    context "when key_stages is blank" do
      it "returns an empty array" do
        expect(key_stages).to eq([])
      end
    end

    context "when the key_stages attribute contains a blank element" do
      let(:attributes) { { key_stages: [ "key_stage_1", nil ] } }

      it "removes the nil element from the key_stages attribute" do
        expect(key_stages).to contain_exactly("key_stage_1")
      end
    end

    context "when the year_groups attribute contains no blank elements" do
      let(:attributes) { { key_stages: %w[early_years key_stage_2] } }

      it "returns the year_groups attribute unchanged" do
        expect(key_stages).to contain_exactly(
          "early_years",
          "key_stage_2",
        )
      end
    end
  end
end
