require 'rails_helper'

RSpec.describe Organisation, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:organisation_contact) }
    it { is_expected.to have_one(:organisation_address) }

    it { is_expected.to have_many(:placement_preferences) }
    it { is_expected.to have_many(:user_memberships) }
    it { is_expected.to have_many(:users).through(:user_memberships) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
