
require "rails_helper"

RSpec.describe AddHostingInterestWizard::NoteToProvidersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(note: nil) }
  end
end
