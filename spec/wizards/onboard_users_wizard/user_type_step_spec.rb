require "rails_helper"

RSpec.describe OnboardUsersWizard::UserTypeStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }
  let(:mock_wizard) { instance_double(OnboardUsersWizard) }
  let(:attributes) { {} }

  describe "validations" do
    context "when user_type is not present" do
      let(:attributes) { { user_type: nil } }

      it "is not valid" do
        expect(step).not_to be_valid
        expect(step.errors[:user_type]).to include("can't be blank")
      end
    end

    context "when user_type is invalid" do
      let(:attributes) { { user_type: "invalid_type" } }

      it "is not valid" do
        expect(step).not_to be_valid
        expect(step.errors[:user_type]).to include("is not included in the list")
      end
    end

    context "when user_type is valid" do
      let(:attributes) { { user_type: "school" } }

      it "is valid" do
        expect(step).to be_valid
      end
    end
  end

  describe "#user_type_options" do
    let(:attributes) { {} }

    it "returns the correct options" do
      options = step.user_type_options
      expect(options.map(&:value)).to contain_exactly("school", "provider")
      expect(options.map(&:name)).to contain_exactly(
        I18n.t("wizards.onboard_users_wizard.user_type_step.options.school"),
        I18n.t("wizards.onboard_users_wizard.user_type_step.options.provider"),
      )
    end
  end
end
