require "rails_helper"

RSpec.describe AddHostingInterestWizard::Interested::PhaseStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "#unknown_option" do
    subject(:unknown_option) { step.unknown_option }

    it "returns the unknown option" do
      expect(unknown_option).to eq(
        OpenStruct.new(
          value: "unknown",
          name: "I don’t know",
        ),
      )
    end
  end
end
