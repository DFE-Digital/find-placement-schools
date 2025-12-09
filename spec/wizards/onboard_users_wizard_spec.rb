require "rails_helper"

RSpec.describe OnboardUsersWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  context "when the user type is school" do
    let(:school) { create(:school, name: "London School", urn: 111111) }

    before { school }

    describe "#steps" do
      subject { wizard.steps.keys }

      context "when there are no errors in the upload step" do
        it { is_expected.to eq(%i[user_type school_upload confirmation]) }
      end

      context "when there are errors in the upload step" do
        let(:csv_content) do
          "urn,first_name,last_name,email_address\r\n" \
          "111111,John,Smith,invalid_email"
        end
        let(:state) do
          {
            "user_type" => {
              "user_type" => "school"
            },
            "school_upload" => {
              "csv_upload" => nil,
              "csv_content" => csv_content
            }
          }
        end

        it { is_expected.to eq(%i[user_type school_upload upload_errors]) }
      end
    end

    describe "#upload_users" do
      subject(:upload_users) { wizard.upload_users }

      let(:state) do
        {
          "user_type" => {
            "user_type" => "school"
          },
          "school_upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content
          }
        }
      end

      context "when the steps are valid" do
        let(:csv_content) do
          "urn,first_name,last_name,email_address\r\n" \
          "111111,John,Smith,john_smith@example.com"
        end

        it "queues a job to create the users" do
          expect { upload_users }.to have_enqueued_job(
            Users::CreateCollectionJob,
          ).exactly(:once)
        end
      end

      context "when a email is invalid" do
        let(:csv_content) do
          "urn,first_name,last_name,email_address\r\n" \
          "111111,John,Smith,invalid_email"
        end

        it "returns an invalid wizard error" do
          expect { upload_users }.to raise_error("Invalid wizard state")
        end
      end
    end
  end

  context "when the user type is provider" do
    let(:provider) { create(:provider, name: "London Provider", ukprn: 11111111) }

    before { provider }

    describe "#steps" do
      subject { wizard.steps.keys }

      let(:state) do
        {
          "user_type" => {
            "user_type" => "provider"
          }
        }
      end

      context "when there are no errors in the upload step" do
        it { is_expected.to eq(%i[user_type provider_upload confirmation]) }
      end

      context "when there are errors in the upload step" do
        let(:csv_content) do
          "ukprn,first_name,last_name,email_address\r\n" \
          "11111111,John,Smith,invalid_email"
        end
        let(:state) do
          {
            "user_type" => {
              "user_type" => "provider"
            },
            "provider_upload" => {
              "csv_upload" => nil,
              "csv_content" => csv_content
            }
          }
        end

        it { is_expected.to eq(%i[user_type provider_upload upload_errors]) }
      end
    end

    describe "#upload_users" do
      subject(:upload_users) { wizard.upload_users }

      let(:state) do
        {
          "user_type" => {
            "user_type" => "provider"
          },
          "provider_upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content
          }
        }
      end

      context "when the steps are valid" do
        let(:csv_content) do
          "ukprn,first_name,last_name,email_address\r\n" \
          "11111111,John,Smith,john_smith@example.com"
        end

        it "queues a job to create the users" do
          expect { upload_users }.to have_enqueued_job(
            Users::CreateCollectionJob,
          ).exactly(:once)
        end
      end

      context "when a email is invalid" do
        let(:csv_content) do
          "ukprn,first_name,last_name,email_address\r\n" \
          "11111111,John,Smith,invalid_email"
        end

        it "returns an invalid wizard error" do
          expect { upload_users }.to raise_error("Invalid wizard state")
        end
      end
    end
  end
end
