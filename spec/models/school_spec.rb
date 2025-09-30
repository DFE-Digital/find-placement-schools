require 'rails_helper'

RSpec.describe School, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_preferences) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:urn) }
  end

  describe "#placement_preference_for" do
    let(:school) { create(:school) }
    let(:academic_year) { AcademicYear.next }
    let!(:placement_preference) { create(:placement_preference, organisation: school, academic_year: academic_year) }

    it "returns the most recent placement preference for the given academic year" do
      expect(school.placement_preference_for(academic_year: academic_year)).to eq(placement_preference)
    end

    context "when there are no placement preferences for the given academic year" do
      it "returns nil" do
        expect(school.placement_preference_for(academic_year: AcademicYear.current)).to be_nil
      end
    end
  end

  describe "#open_to_hosting_for" do
    subject(:open_to_hosting_for) { described_class.open_to_hosting_for(academic_year) }

    let(:academic_year) { AcademicYear.next }
    let(:actively_looking_school) do
      create(
        :school,
        name: "London Primary School",
        phase: "All-through",
        placement_preferences: [ build(:placement_preference, appetite: "actively_looking", academic_year:, placement_details: {
          "secondary_subject_selection" => {
            "subject_ids" => [ "1234" ]
          }
        }) ]
      )
    end
    let(:not_hosting_school) do
      create(
        :school,
        name: "Brixton Primary School",
        phase: "All-through",
        placement_preferences: [ build(:placement_preference, appetite: "not_open", academic_year:, placement_details: {
          "secondary_subject_selection" => {
            "subject_ids" => [ "1234" ]
          }
        }) ]
      )
    end
    let(:previous_hosted_school) do
      create(
        :school,
        name: "Brixton Primary School",
        phase: "All-through",
        previous_placements: [ build(:previous_placement, academic_year:) ],
      )
    end
    let(:not_onboarded_school) do
      create(:school)
    end

    before do
      actively_looking_school
      not_hosting_school
      previous_hosted_school
      not_onboarded_school
    end

    it "returns schools who are open to hosting or have previously hosted placements" do
      expect(open_to_hosting_for).to contain_exactly(actively_looking_school, previous_hosted_school)
    end
  end
end
