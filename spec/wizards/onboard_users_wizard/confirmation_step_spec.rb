require "rails_helper"

RSpec.describe OnboardUsersWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  context "when uploading school users" do
    let(:mock_wizard) do
      instance_double(OnboardUsersWizard).tap do |mock_wizard|
        allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step }, upload_step: mock_upload_step)
      end
    end

    let(:mock_upload_step) do
      instance_double(OnboardUsersWizard::SchoolUploadStep).tap do |mock_upload_step|
        allow(mock_upload_step).to receive_messages(
          invalid_email_address_rows:,
          invalid_identifier_rows:,
          file_name:,
          csv:,
        )
      end
    end
    let(:attributes) { nil }
    let(:invalid_email_address_rows) { nil }
    let(:invalid_identifier_rows) { nil }
    let(:file_name) { "uploaded.csv" }
    let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
    let(:csv_content) do
      "urn,first_name,last_name,email_address\r\n" \
      "111111,John,Smith,john_smith@example.com"
    end

    describe "delegations" do
      it { is_expected.to delegate_method(:csv).to(:upload_step) }
      it { is_expected.to delegate_method(:file_name).to(:upload_step) }
    end

    describe "#csv_headers" do
      it "returns the headers of the CSV file" do
        expect(step.csv_headers).to match_array(
          %w[urn first_name last_name email_address],
        )
      end
    end
  end

  context "when uploading provider users" do
    let(:mock_wizard) do
      instance_double(OnboardUsersWizard).tap do |mock_wizard|
        allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step }, upload_step: mock_upload_step)
      end
    end

    let(:mock_upload_step) do
      instance_double(OnboardUsersWizard::ProviderUploadStep).tap do |mock_upload_step|
        allow(mock_upload_step).to receive_messages(
                                     invalid_email_address_rows:,
                                     invalid_identifier_rows:,
                                     file_name:,
                                     csv:,
                                     )
      end
    end
    let(:attributes) { nil }
    let(:invalid_email_address_rows) { nil }
    let(:invalid_identifier_rows) { nil }
    let(:file_name) { "uploaded.csv" }
    let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
    let(:csv_content) do
      "ukprn,first_name,last_name,email_address\r\n" \
        "10052837,John,Smith,john_smith@example.com"
    end

    describe "delegations" do
      it { is_expected.to delegate_method(:csv).to(:upload_step) }
      it { is_expected.to delegate_method(:file_name).to(:upload_step) }
    end

    describe "#csv_headers" do
      it "returns the headers of the CSV file" do
        expect(step.csv_headers).to match_array(
          %w[ukprn first_name last_name email_address],
        )
      end
    end
  end
end
