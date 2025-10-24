require "rails_helper"

RSpec.describe OnboardUsersWizard::UploadErrorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  context "when uploading school users" do
    let(:mock_wizard) do
      instance_double(OnboardUsersWizard).tap do |mock_wizard|
        allow(mock_wizard).to receive_messages(
                                steps: { user_type: mock_user_type_step, school_upload_spec: mock_upload_step },
                                upload_step: mock_upload_step
                              )
      end
    end
    let(:mock_user_type_step) do
      instance_double(OnboardUsersWizard::UserTypeStep).tap do |mock_user_type_step|
        allow(mock_user_type_step).to receive_messages(user_type: "school")
      end
    end

    let(:mock_upload_step) do
      instance_double(OnboardUsersWizard::SchoolUploadStep).tap do |mock_upload_step|
        allow(mock_upload_step).to receive_messages(
          csv_content:,
          file_name:,
          invalid_identifier_rows:,
          invalid_email_address_rows:,
          missing_first_name_rows:,
          missing_last_name_rows:,
        )
      end
    end
    let(:attributes) { nil }
    let(:csv_content) { nil }
    let(:file_name) { nil }
    let(:invalid_identifier_rows) { [] }
    let(:invalid_email_address_rows) { [] }
    let(:missing_first_name_rows) { [] }
    let(:missing_last_name_rows) { [] }

    describe "delegations" do
      it { is_expected.to delegate_method(:invalid_identifier_rows).to(:upload_step) }
      it { is_expected.to delegate_method(:invalid_email_address_rows).to(:upload_step) }
      it { is_expected.to delegate_method(:missing_first_name_rows).to(:upload_step) }
      it { is_expected.to delegate_method(:missing_last_name_rows).to(:upload_step) }
      it { is_expected.to delegate_method(:file_name).to(:upload_step) }
      it { is_expected.to delegate_method(:csv).to(:upload_step) }
    end

    describe "#row_indexes_with_errors" do
      subject(:row_indexes_with_errors) { step.row_indexes_with_errors }

      let(:invalid_email_address_rows) { [ 1 ] }
      let(:invalid_identifier_rows) { [ 1, 2, 3 ] }
      let(:missing_first_name_rows) { [ 3, 4 ] }
      let(:missing_last_name_rows) { [ 4, 5 ] }

      it "merges all the validation attributes containing row numbers together (removing duplicates)" do
        expect(row_indexes_with_errors).to contain_exactly(1, 2, 3, 4, 5)
      end
    end

    describe "#error_count" do
      subject(:error_count) { step.error_count }

      let(:invalid_email_address_rows) { [ 1 ] }
      let(:invalid_identifier_rows) { [ 1, 2, 3, 4 ] }
      let(:missing_first_name_rows) { [ 3, 4 ] }
      let(:missing_last_name_rows) { [ 3, 4 ] }

      it "adds together the number of elements in validation attribute" do
        expect(error_count).to eq(9)
      end
    end
  end
end
