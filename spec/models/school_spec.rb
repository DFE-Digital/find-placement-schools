require 'rails_helper'

RSpec.describe School, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_preferences) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:urn) }
  end

  describe "#current_hosting_interest" do
    let(:school) { create(:school) }
    let(:academic_year) { AcademicYear.current.next }
    let!(:placement_preference) { create(:placement_preference, organisation: school, academic_year: academic_year) }

    it "returns the most recent placement preference for the given academic year" do
      expect(school.current_hosting_interest(academic_year: academic_year)).to eq(placement_preference)
    end

    context "when there are no placement preferences for the given academic year" do
      it "returns nil" do
        expect(school.current_hosting_interest(academic_year: AcademicYear.current)).to be_nil
      end
    end
  end
end
