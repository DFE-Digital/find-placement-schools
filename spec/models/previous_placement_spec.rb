require 'rails_helper'

RSpec.describe PreviousPlacement, type: :model do
  subject(:previous_placement) { build(:previous_placement) }

  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:academic_year) }
  end

  describe "validations" do
    it {
      is_expected.to validate_uniqueness_of(:school_id)
                       .scoped_to(:subject_name, :academic_year_id)
                       .ignoring_case_sensitivity
    }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:academic_year).with_prefix }
  end

  describe "scopes" do
    describe ".order_by_name" do
      let(:academic_year) { AcademicYear.current }
      let!(:placement_a) { create(:previous_placement, subject_name: "Biology", academic_year:) }
      let!(:placement_b) { create(:previous_placement, subject_name: "Art", academic_year:) }

      it "orders previous placements by subject_name" do
        expect(PreviousPlacement.order_by_name).to eq([ placement_b, placement_a ])
      end
    end
  end
end
