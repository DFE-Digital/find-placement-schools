require "rails_helper"

RSpec.describe AddHostingInterestWizard::AcademicYearStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(AddHostingInterestWizard)
  end

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(academic_year_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:academic_year_id) }
  end

  describe "#academic_year_options" do
    subject(:appetite_options) { step.appetite_options }

    let!(:current_academic_year) { create(:academic_year, :current) }
    let!(:next_academic_year) { create(:academic_year, :next) }
    let(:school) { build(:school) }

    before do
      allow(mock_wizard).to receive(:school).and_return(school)
    end

    it "returns struct objects for each academic year" do
      expect(step.academic_year_options.map(&:value)).to match_array([ current_academic_year.id, next_academic_year.id ])
      expect(step.academic_year_options.map(&:name)).to match_array([ current_academic_year.name, next_academic_year.name ])
    end
  end
end
