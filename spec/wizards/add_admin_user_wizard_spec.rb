require "rails_helper"

RSpec.describe AddAdminUserWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "delegations" do
    it { is_expected.to delegate_method(:first_name).to(:user).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:last_name).to(:user).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:email_address).to(:user).with_prefix.allow_nil }
  end

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[admin_user check_your_answers] }
  end

  describe "#create_user" do
    subject(:create_user) { wizard.create_user }

    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:email_address) { "john_doe@education.gov.uk" }
    let(:state) do
      {
        "admin_user" => {
          "first_name" => first_name,
          "last_name" => last_name,
          "email_address" => email_address
        }
      }
    end

    context "when the user does not already exist" do
      it "creates a new admin user" do
        expect { create_user }.to change(
          User, :count
        )

        user = User.find_by(first_name:, last_name:, email_address:)
        expect(user.admin?).to be_truthy
      end
    end

    context "when the user already exists" do
      let!(:user) { create(:user, first_name:, last_name:, email_address:) }

      it "does not duplicate the user" do
        expect { create_user }.to not_change(
          User, :count
        )
      end
    end
  end
end
