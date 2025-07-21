require 'rails_helper'

RSpec.describe PlacementPreference, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:academic_year) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
  end

  describe "enums" do
    subject(:placement_preference) { build(:placement_preference, appetite: :actively_looking) }

    it "defines the expected values" do
      expect(placement_preference).to define_enum_for(:appetite)
        .with_values(
          actively_looking: "actively_looking",
          interested: "interested",
          not_open: "not_open",
        )
        .backed_by_column_of_type(:enum)
    end
  end
end
