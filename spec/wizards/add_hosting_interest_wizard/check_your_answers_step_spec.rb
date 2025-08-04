require "rails_helper"

RSpec.describe AddHostingInterestWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }
  let(:placement_subject) { create(:placement_subject, name: "English") }

  describe "delegations" do
    it { is_expected.to delegate_method(:phases).to(:phase_step) }
    it { is_expected.to delegate_method(:year_groups).to(:wizard) }
    it { is_expected.to delegate_method(:selected_secondary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:key_stages).to(:wizard) }
    it { is_expected.to delegate_method(:first_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:last_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:email_address).to(:school_contact_step).with_prefix(:school_contact) }
  end
end
