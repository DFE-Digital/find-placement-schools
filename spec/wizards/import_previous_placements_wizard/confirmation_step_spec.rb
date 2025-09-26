require "rails_helper"

RSpec.describe ImportPreviousPlacementsWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(ImportPreviousPlacementsWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(ImportPreviousPlacementsWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
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

  describe "delegations" do
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
  end

  describe "#csv_headers" do
    it "returns the headers of the CSV file" do
      expect(step.csv_headers).to match_array(
        %w[academic_year_start_date school_urn subject_name subject_code number_of_placements],
      )
    end
  end
end
