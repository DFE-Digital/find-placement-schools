require "rails_helper"

RSpec.describe ImportPreviousPlacementsWizard::UploadErrorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(ImportPreviousPlacementsWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(ImportPreviousPlacementsWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        missing_academic_year_rows:,
        invalid_school_urn_rows:,
        missing_subject_name_rows:,
        invalid_subject_code_rows:,
        invalid_number_of_placements_rows:,
        file_name:,
        csv:,
      )
    end
  end
  let(:attributes) { nil }
  let(:file_name) { "uploaded.csv" }
  let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
  let(:csv_content) do
    "academic_year_start_date,school_urn,subject_name,subject_code,number_of_placements\r\n" \
      "2025-09-01,123456,Computing,11,5"
  end
  let(:missing_academic_year_rows) { nil }
  let(:invalid_school_urn_rows) { nil }
  let(:missing_subject_name_rows) { nil }
  let(:invalid_subject_code_rows) { nil }
  let(:invalid_number_of_placements_rows) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:missing_academic_year_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:invalid_school_urn_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:missing_subject_name_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:invalid_subject_code_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:invalid_number_of_placements_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
  end

  describe "#row_indexes_with_errors" do
    subject(:row_indexes_with_errors) { step.row_indexes_with_errors }

    let(:missing_academic_year_rows) { [ 1 ] }
    let(:invalid_school_urn_rows) { [ 2 ] }
    let(:missing_subject_name_rows) { [ 3 ] }
    let(:invalid_subject_code_rows) { [ 4 ] }
    let(:invalid_number_of_placements_rows) { [ 6, 7 ] }

    it "merges all the validation attributes containing row numbers together (removing duplicates)" do
      expect(row_indexes_with_errors).to contain_exactly(1, 2, 3, 4, 6, 7)
    end
  end

  describe "#error_count" do
    subject(:error_count) { step.error_count }

    let(:missing_academic_year_rows) { [ 1 ] }
    let(:invalid_school_urn_rows) { [ 2 ] }
    let(:missing_subject_name_rows) { [ 3 ] }
    let(:invalid_subject_code_rows) { [ 4 ] }
    let(:invalid_number_of_placements_rows) { [ 6, 7 ] }

    it "adds together the number of elements in validation attribute" do
      expect(error_count).to eq(6)
    end
  end
end
