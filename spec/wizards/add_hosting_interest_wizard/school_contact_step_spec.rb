require "rails_helper"

RSpec.describe AddHostingInterestWizard::SchoolContactStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(first_name: nil, last_name: nil, email_address: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email_address) }
    it { is_expected.to allow_value("name@example.com").for(:email_address) }
    it { is_expected.not_to allow_value("some_text").for(:email_address) }
  end
end
