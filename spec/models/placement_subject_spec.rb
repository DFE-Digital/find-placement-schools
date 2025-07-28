require 'rails_helper'

RSpec.describe PlacementSubject, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:parent_subject).optional }
    it { is_expected.to have_many(:child_subjects) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "enums" do
    subject(:placement_subject) { build(:placement_subject) }

    it "defines the expected values" do
      expect(placement_subject).to define_enum_for(:phase)
        .with_values(primary: "primary", secondary: "secondary")
        .backed_by_column_of_type(:enum)
    end
  end
end
