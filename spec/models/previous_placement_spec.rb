require 'rails_helper'

RSpec.describe PreviousPlacement, type: :model do
  subject(:previous_placement) { build(:previous_placement) }

  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:placement_subject) }
    it { is_expected.to belong_to(:academic_year) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:school_id).scoped_to(:placement_subject_id, :academic_year_id).case_insensitive }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:placement_subject).with_prefix }
    it { is_expected.to delegate_method(:name).to(:academic_year).with_prefix }

  end
end
