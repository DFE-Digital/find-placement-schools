require "rails_helper"

RSpec.describe AddHostingInterestWizard::YearGroupSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(year_groups: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:year_groups) }
  end

  describe "#year_groups_for_selection" do
    subject(:year_groups_for_selection) { step.year_groups_for_selection }

    it "returns all year groups, expect for mixed year group" do
      expect(year_groups_for_selection).to eq(
        [
          OpenStruct.new(value: "nursery", name: "Nursery", description: "3 to 4 years"),
          OpenStruct.new(value: "reception", name: "Reception", description: "4 to 5 years"),
          OpenStruct.new(value: "year_1", name: "Year 1", description: "5 to 6 years"),
          OpenStruct.new(value: "year_2", name: "Year 2", description: "6 to 7 years"),
          OpenStruct.new(value: "year_3", name: "Year 3", description: "7 to 8 years"),
          OpenStruct.new(value: "year_4", name: "Year 4", description: "8 to 9 years"),
          OpenStruct.new(value: "year_5", name: "Year 5", description: "9 to 10 years"),
          OpenStruct.new(value: "year_6", name: "Year 6", description: "10 to 11 years"),
          OpenStruct.new(value: "mixed_year_groups", name: "Mixed year groups", description: "")
        ],
      )
    end
  end

  describe "#year_groups" do
    subject(:year_groups) { step.year_groups }

    context "when year_groups is blank" do
      it "returns an empty array" do
        expect(year_groups).to eq([])
      end
    end

    context "when the year_groups attribute contains a blank element" do
      let(:attributes) { { year_groups: [ "year_1", nil ] } }

      it "removes the nil element from the year_groups attribute" do
        expect(year_groups).to contain_exactly("year_1")
      end
    end

    context "when the year_groups attribute contains no blank elements" do
      let(:attributes) { { year_groups: %w[reception year_2] } }

      it "returns the year_groups attribute unchanged" do
        expect(year_groups).to contain_exactly(
          "reception",
          "year_2",
        )
      end
    end
  end

  describe "#unknown_option" do
    subject(:unknown_option) { step.unknown_option }

    it "returns the unknown option" do
      expect(unknown_option).to eq(
        OpenStruct.new(
          value: "unknown",
          name: "I don’t know",
        ),
      )
    end
  end
end
