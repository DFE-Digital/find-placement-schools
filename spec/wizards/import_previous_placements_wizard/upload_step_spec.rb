require "rails_helper"

RSpec.describe ImportPreviousPlacementsWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(ImportPreviousPlacementsWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it {
      expect(step).to have_attributes(
        csv_upload: nil,
        csv_content: nil,
        file_name: nil,
        missing_academic_year_rows: [],
        invalid_school_urn_rows: [],
        missing_subject_name_rows: [],
      )
    }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) do
          "academic_year_start_date,school_urn,subject_name,subject_code,number_of_placements\r\n" \
            "2025-09-01,123456,Computing,11,5"
        end
        let(:attributes) { { csv_content: } }

        it { is_expected.not_to validate_presence_of(:csv_upload) }
      end
    end

    describe "#validate_csv_file" do
      context "when the csv_upload is present" do
        context "when the csv_upload is not a CSV" do
          let(:attributes) { { csv_upload: invalid_file } }
          let(:invalid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "invalid.jpg",
              type: "image/jpeg",
              tempfile: Tempfile.new("invalid.jpg")
            })
          end

          it "validates that the file is the incorrect format" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include("The selected file must be a CSV")
          end
        end

        context "when the csv_upload is a CSV file" do
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open("spec/fixtures/register_trainee_teachers/import.csv")
            })
          end

          it "validates that the file is the correct format" do
            expect(step.valid?).to be(true)
          end
        end
      end
    end

    describe "#validate_csv_headers" do
      context "when csv_content is present" do
        context "when the csv content is missing valid headers" do
          let(:csv_content) do
            "school_urn\r\n"
          end
          let(:attributes) { { csv_content: } }

          it "returns errors for missing headers" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include(
              "Your file needs a column called ‘academic_year_start_date’ and ‘subject_name’.",
            )
            expect(step.errors.messages[:csv_upload]).to include(
              "Right now it has columns called ‘school_urn’.",
            )
          end
        end
      end
    end

    describe "#csv_inputs_valid?" do
      subject(:csv_inputs_valid) { step.csv_inputs_valid? }

      context "when the csv_content is blank" do
        it "returns true" do
          expect(csv_inputs_valid).to be(true)
        end
      end

      context "when the csv_content is missing an academic_year_start_date" do
        let(:csv_content) do
          "academic_year_start_date,school_urn,subject_name,subject_code\r\n" \
            ",123456,Computing,11"
        end
        let(:attributes) { { csv_content: } }

        it "returns false and assigns the csv row to the 'missing_academic_year_rows' attribute" do
          expect(csv_inputs_valid).to be(false)
          expect(step.missing_academic_year_rows).to contain_exactly(0)
        end
      end

      context "when csv_content contains invalid school urn" do
        let(:csv_content) do
          "academic_year_start_date,school_urn,subject_name,subject_code\r\n" \
            "2025-09-01,123456,Computing,11"
        end
        let(:attributes) { { csv_content: } }

        it "returns false and assigns the csv row to the 'invalid_school_urn_rows' attribute" do
          expect(csv_inputs_valid).to be(false)
          expect(step.invalid_school_urn_rows).to contain_exactly(0)
        end
      end

      context "when csv_content is missing an subject_name" do
        let(:csv_content) do
          "academic_year_start_date,school_urn,subject_name,subject_code\r\n" \
            "2025-09-01,123456,,11"
        end
        let(:attributes) { { csv_content: } }

        it "returns false and assigns the csv row to the 'missing_subject_name_rows' attribute" do
          expect(csv_inputs_valid).to be(false)
          expect(step.missing_subject_name_rows).to contain_exactly(0)
        end
      end

      context "when the csv_content contains valid attributes" do
        let(:school) { create(:school) }
        let(:academic_year) { create(:academic_year, :current) }
        let(:placement_subject) { create(:placement_subject) }
        let(:csv_content) do
          "academic_year_start_date,school_urn,subject_name\r\n" \
            "#{academic_year.starts_on},#{school.urn},#{placement_subject.name},#{placement_subject.code}"
        end
        let(:attributes) { { csv_content: } }

        it "returns true" do
          expect(csv_inputs_valid).to be(true)
        end
      end
    end

    describe "#process_csv" do
      let(:attributes) { { csv_upload: valid_file } }
      let(:valid_file) do
        ActionDispatch::Http::UploadedFile.new({
          filename: "valid.csv",
          type: "text/csv",
          tempfile: File.open("spec/fixtures/register_trainee_teachers/import.csv")
        })
      end

      before do
        create(:academic_year, name: "2025 to 2026", starts_on: "2025-09-01", ends_on: "2026-08-30")
        create(:school, urn: "100003")
        create(:placement_subject, name: "Computing", code: "11")
      end

      it "reads a given CSV and assigns the content to the csv_content attribute,
        and assigns the associated claim IDs to the claim_ids attribute" do
        expect(step.csv_content).to eq(
          "academic_year_start_date,school_urn,subject_name\n2025-09-01,100003,Computing\n"
        )
      end
    end

    describe "#csv" do
      subject(:csv) { step.csv }

      let(:csv_content) do
        "academic_year_start_date,school_urn,subject_name\r\n" \
          "2025-09-01,123456,Computing"
      end
      let(:attributes) { { csv_content: } }

      it "converts the csv content into a CSV record" do
        expect(csv).to be_a(CSV::Table)
        expect(csv.headers).to match_array(
          %w[academic_year_start_date school_urn subject_name],
        )
        expect(csv.count).to eq(1)

        expect(csv[0]).to be_a(CSV::Row)
        expect(csv[0].to_h).to eq({
          "academic_year_start_date" => "2025-09-01",
          "school_urn" => "123456",
          "subject_name" => "Computing"
        })
      end
    end
  end
end
