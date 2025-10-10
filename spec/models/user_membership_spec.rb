require 'rails_helper'

RSpec.describe UserMembership, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organisation) }
  end

  describe "validations" do
    subject { create(:user_membership) }

    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:organisation_id) }
  end
end
