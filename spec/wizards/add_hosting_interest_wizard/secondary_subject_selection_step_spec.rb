require "rails_helper"

RSpec.describe AddHostingInterestWizard::SecondarySubjectSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:stem_subjects).to(:subjects_for_selection) }
    it { is_expected.to delegate_method(:lit_lang_subjects).to(:subjects_for_selection) }
    it { is_expected.to delegate_method(:art_humanities_social_subjects).to(:subjects_for_selection) }
    it { is_expected.to delegate_method(:health_physical_education_subjects).to(:subjects_for_selection) }
  end

  describe "attributes" do
    it { is_expected.to have_attributes(subject_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject_ids) }
  end

  describe "#subjects_for_selection" do
    subject(:subjects_for_selection) { step.subjects_for_selection }

    let(:primary_subject) { create(:placement_subject, :primary, name: "Primary") }
    let!(:english) { create(:placement_subject, :secondary, name: "English") }
    let!(:mathematics) { create(:placement_subject, :secondary, name: "Mathematics") }
    let!(:science) { create(:placement_subject, :secondary, name: "Science") }

    before { primary_subject }

    it "returns only secondary subjects" do
      expect(subjects_for_selection).to contain_exactly(
        english,
        mathematics,
        science,
      )
    end
  end

  describe "#subject_ids" do
    subject(:subject_ids) { step.subject_ids }

    context "when subject_ids is blank" do
      it "returns an empty array" do
        expect(subject_ids).to eq([])
      end
    end

    context "when the subject_ids attribute contains a blank element" do
      let(:attributes) { { subject_ids: [ "123", nil ] } }

      it "removes the nil element from the subject_ids attribute" do
        expect(subject_ids).to contain_exactly("123")
      end
    end

    context "when the subject_ids attribute contains no blank elements" do
      let(:attributes) { { subject_ids: %w[123 456] } }

      it "returns the subject_ids attribute unchanged" do
        expect(subject_ids).to contain_exactly(
          "123",
          "456",
        )
      end
    end
  end
end
