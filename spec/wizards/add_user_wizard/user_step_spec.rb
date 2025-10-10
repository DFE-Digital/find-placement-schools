require "rails_helper"

RSpec.describe AddUserWizard::UserStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddUserWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:organisation).and_return(organisation)
    end
  end
  let(:organisation) { create(:school) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(first_name: nil, last_name: nil, email_address: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email_address) }
    it { is_expected.to allow_value("name@example.com").for(:email_address) }
    it { is_expected.not_to allow_value("some_text").for(:email_address) }

    describe "#new_membership" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email_address) { "john_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email_address: } }

      context "when the user is not already associated with the organisation" do
        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end

      context "when the user is already associated with the organisation" do
        let(:user) { create(:user, first_name:, last_name:, email_address:) }
        let(:membership) { create(:user_membership, user:, organisation:) }

        before do
          membership
        end

        it "returns invalid" do
          expect(step.valid?).to be(false)
        end
      end
    end

    describe "#user" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email_address) { "john_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email_address: } }

      context "when the user does not already exist" do
        it "returns a new record" do
          user = step.user
          expect(user.new_record?).to be(true)
          expect(user.first_name).to eq(first_name)
          expect(user.last_name).to eq(last_name)
          expect(user.email_address).to eq(email_address)
        end
      end

      context "when the user already exists" do
        let!(:existing_user) { create(:user, first_name:, last_name:, email_address:) }

        it "returns the existing user record" do
          user = step.user
          expect(user.new_record?).to be(false)
          expect(user).to eq(existing_user)
        end
      end

      context "when the first name or last name do not match the user record attributes" do
        let!(:existing_user) { create(:user, first_name: "Jake", last_name: "Bloggs", email_address:) }

        it "returns the existing user record, with reassigned attributes" do
          user = step.user
          expect(user.new_record?).to be(false)
          expect(user.id).to eq(existing_user.id)
          expect(user.email_address).to eq(existing_user.email_address)
          expect(user.first_name).not_to eq(existing_user.first_name)
          expect(user.first_name).to eq(first_name)
          expect(user.last_name).not_to eq(existing_user.last_name)
          expect(user.last_name).to eq(last_name)
        end
      end
    end

    describe "#membership" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email_address) { "john_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email_address: } }
      let!(:user) { create(:user, first_name:, last_name:, email_address:) }

      it "returns a new membership between the user and the organisation" do
        membership = step.membership
        expect(membership.new_record?).to be(true)
        expect(membership.user).to eq(user)
        expect(membership.organisation).to eq(organisation)
      end
    end
  end
end
