require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:selected_organisation).optional }

    it { is_expected.to have_many(:user_memberships) }

    it { is_expected.to have_many(:organisations).through(:user_memberships) }
    it { is_expected.to have_many(:schools).class_name("Organisation").through(:user_memberships).source(:organisation) }
    it { is_expected.to have_many(:providers).class_name("Organisation").through(:user_memberships).source(:organisation) }

    it { is_expected.to have_many(:placement_preferences).class_name("PlacementPreference") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email_address) }
  end

  describe "scopes" do
    describe ".admin" do
      let!(:admin_user) { create(:user, admin: true) }
      let!(:regular_user) { create(:user, admin: false) }

      it "returns only admin users" do
        expect(User.admin).to include(admin_user)
        expect(User.admin).not_to include(regular_user)
      end
    end
  end

  describe "#full_name" do
    let(:user) { build(:user, first_name: "Jane", last_name: "Smith") }

    it "returns the full name of the user" do
      expect(user.full_name).to eq("Jane Smith")
    end
  end
end
