require "rails_helper"

RSpec.describe UserPolicy do
  subject(:user_policy) { described_class }

  describe "scope" do
    let(:scope) { User.all }

    before do
      create_list(:user, 3)
    end

    context "when the user is an admin user" do
      let(:user) { create(:user, :admin) }

      it "returns all users" do
        expect(user_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a member of an organisation" do
      let(:school) { build(:school) }
      let!(:school_user) { create(:user, organisations: [ school ], selected_organisation: school) }
      let(:other_user) { create(:user) }

      before do
        other_user
      end

      it "returns the current organisation's users" do
        expect(user_policy::Scope.new(school_user, scope).resolve).to eq([ school_user ])
      end
    end

    context "when the user is none of the above" do
      let(:user) { create(:user) }

      it "returns the user's organisations" do
        expect(user_policy::Scope.new(user, scope).resolve).to be_empty
      end
    end
  end

  permissions :index?, :new? do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "permits access" do
      expect(user_policy).to permit(user, other_user)
    end
  end

  permissions :show?, :edit?, :update?, :destroy? do
    context "when the user is a member of an organisation" do
      let(:school) { build(:school) }
      let(:user) { create(:user, organisations: [ school ], selected_organisation: school) }
      let(:member) { create(:user, organisations: [ school ]) }
      let(:non_member) { create(:user) }

      it "permits access to other members of the organisation" do
        expect(user_policy).to permit(user, member)
      end

      it "denies access to non-members of the organisation" do
        expect(user_policy).not_to permit(user, non_member)
      end
    end
  end
end
