require "rails_helper"

RSpec.describe ImportPreviousPlacementsWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:academic_year) { create(:academic_year, :current) }
  let(:school) { create(:school) }
  let(:placement_subject) { create(:placement_subject) }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    context "when the csv input is blank" do
      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when the csv input is invalid" do
      let(:csv_content) do
        "academic_year_start_date,school_urn,subject_name,subject_code,number_of_placements\r\n" \
          "2025-09-01,123456,,11,5"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content
          }
        }
      end

      it { is_expected.to eq(%i[upload upload_errors]) }
    end

    context "when the csv input is valid" do
      let(:csv_content) do
        "academic_year_start_date,school_urn,subject_name,subject_code,number_of_placements\r\n" \
          "#{academic_year.starts_on},#{school.urn},#{placement_subject.name},#{placement_subject.code},5"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content
          }
        }
      end

      it { is_expected.to eq(%i[upload confirmation]) }
    end
  end

  describe "#import_previous_placements" do
    subject(:import_previous_placements) { wizard.import_previous_placements }

    context "when the steps are valid" do
      let(:csv_content) do
        "academic_year_start_date,school_urn,subject_name\r\n" \
          "#{academic_year.starts_on},#{school.urn},#{placement_subject.name}"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content
          }
        }
      end

      it "queues a job" do
        expect { import_previous_placements }.to have_enqueued_job(
          RegisterTraineeTeachers::ImportPlacementDataJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      context "when the a step is invalid" do
        let(:csv_content) { nil }

        it "returns an invalid wizard error" do
          expect { import_previous_placements }.to raise_error("Invalid wizard state")
        end
      end

      context "when the uploaded content includes an invalid input" do
        let(:csv_content) do
          "academic_year_start_date,school_urn,subject_name\r\n" \
            "2025-09-01,123456,,"
        end
        let(:state) do
          {
            "upload" => {
              "csv_upload" => nil,
              "csv_content" => csv_content
            }
          }
        end

        it "returns an invalid wizard error" do
          expect { import_previous_placements }.to raise_error("Invalid wizard state")
        end
      end
    end
  end
end
