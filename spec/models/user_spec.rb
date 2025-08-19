require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:selected_organisation).optional }

    it { is_expected.to have_many(:user_memberships) }
    it { is_expected.to have_many(:organisations).through(:user_memberships) }
    it { is_expected.to have_many(:placement_preferences).class_name("PlacementPreference") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email_address) }
  end
end
