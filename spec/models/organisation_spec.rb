require 'rails_helper'

RSpec.describe Organisation, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:organisation_contact) }
    it { is_expected.to have_one(:organisation_address) }

    it { is_expected.to have_many(:user_memberships) }
    it { is_expected.to have_many(:users).through(:user_memberships) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:address_1).to(:organisation_address).allow_nil }
    it { is_expected.to delegate_method(:address_2).to(:organisation_address).allow_nil }
    it { is_expected.to delegate_method(:address_3).to(:organisation_address).allow_nil }
    it { is_expected.to delegate_method(:town).to(:organisation_address).allow_nil }
    it { is_expected.to delegate_method(:postcode).to(:organisation_address).allow_nil }
  end
end
