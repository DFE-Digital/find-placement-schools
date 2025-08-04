require "rails_helper"

RSpec.describe AddHostingInterestWizard::ConfirmStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:note).to(:note_to_providers_step) }
  end
end
