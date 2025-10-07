require "rails_helper"

RSpec.describe AddUserWizard do
  subject(:wizard) { described_class.new(state:, params:, organisation: school, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:school) }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[user check_your_answers] }
  end

  describe "#create_user" do
    subject(:create_user) { wizard.create_user }

    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:email_address) { "john_doe@example.com" }
    let(:state) do
      {
        "user" => {
          "first_name" => first_name,
          "last_name" => last_name,
          "email_address" => email_address
        }
      }
    end

    context "when the user does not already exist" do
      it "creates a new user, and a membership between the user and school" do
        expect { create_user }.to change(
          User, :count
        ).by(1).and change(UserMembership, :count).by(1)

        user = User.find_by(first_name:, last_name:, email_address:)
        expect(user.organisations).to contain_exactly(school)
      end
    end

    context "when the user already exists" do
      let!(:user) { create(:user, first_name:, last_name:, email_address:) }

      it "creates a membership between the user and school" do
        expect { create_user }.to not_change(
          User, :count
        ).and change(UserMembership, :count).by(1)

        expect(user.organisations).to contain_exactly(school)
      end
    end

    context "when the user and membership already exist" do
      let(:user) { create(:user, first_name:, last_name:, email_address:) }
      let(:membership) { create(:user_membership, user:, organisation: school) }

      before do
        user
        membership
      end

      it "returns an error" do
        expect { create_user }.to raise_error("Invalid wizard state")
      end
    end
  end
end
