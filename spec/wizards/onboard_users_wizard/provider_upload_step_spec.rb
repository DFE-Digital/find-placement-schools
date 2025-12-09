require "rails_helper"

RSpec.describe OnboardUsersWizard::ProviderUploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(OnboardUsersWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(steps: { user_type: mock_user_type_step })
    end
  end
  let(:attributes) { nil }

  let(:mock_user_type_step) do
    instance_double(OnboardUsersWizard::UserTypeStep).tap do |mock_user_type_step|
      allow(mock_user_type_step).to receive_messages(user_type: "school")
    end
  end

  describe "attributes" do
    it {
      expect(step).to have_attributes(
                        csv_upload: nil,
                        csv_content: nil,
                        file_name: nil,
                        missing_first_name_rows: [],
                        missing_last_name_rows: [],
                        invalid_email_address_rows: [],
                        invalid_identifier_rows: [],
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
          "ukprn,first_name,last_name,email_address\r\n" \
            "10052837,John,Smith,john_smith@example.com"
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
                                                     tempfile: File.open(
                                                       "spec/fixtures/importers/provider_users.csv",
                                                       )
                                                   })
          end
          let(:london_provider) { create(:provider, name: "London Provider", ukprn: 111_111) }
          let(:guildford_provider) { create(:provider, name: "Guildford Provider", ukprn: 222_222) }

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
            "something_random\r\n" \
              "blah"
          end
          let(:attributes) { { csv_content: } }

          it "returns errors for missing headers" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include(
                                                           "Your file needs a column called ‘ukprn’, ‘email_address’, ‘first_name’, and ‘last_name’.",
                                                           )
            expect(step.errors.messages[:csv_upload]).to include(
                                                           "Right now it has columns called ‘something_random’.",
                                                           )
          end
        end
      end
    end
  end

  describe "#csv_inputs_valid?" do
    subject(:csv_inputs_valid) { step.csv_inputs_valid? }

    before { create(:provider, name: "London Provider", ukprn: "10052837") }

    context "when the csv_content is blank" do
      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end

    context "when csv_content contains invalid email_address" do
      let(:csv_content) do
        "ukprn,first_name,last_name,email_address\r\n" \
          "10052837,John,Smith,invalid_email"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns the csv row to the 'invalid_email_address_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_email_address_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains missing first_name" do
      let(:csv_content) do
        "ukprn,first_name,last_name,email_address\r\n" \
          "10052837,James,Samson,test@sample.com\r\n" \
          "10052837,,Smith,test@sample.com"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns the csv row to the missing first_name attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_first_name_rows).to contain_exactly(1)
      end
    end

    context "when csv_content contains missing last_name attribute" do
      let(:csv_content) do
        "ukprn,first_name,last_name,email_address\r\n" \
          "10052837,James,,test@sample.com\r\n" \
          "10052837,James,Samson,test@sample.com"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns the csv row to the missing last_name attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_last_name_rows).to contain_exactly(0)
      end
    end

    context "when the csv_content contains valid email_address, ukprn, and all necessary valid attributes" do
      let(:csv_content) do
        "ukprn,first_name,last_name,email_address\r\n" \
          "10052837,John,Smith,john_smith@example.com\r\n" \
          ",,,,"
      end
      let(:attributes) { { csv_content: } }

      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end
  end

  describe "#process_csv" do
    let(:london_provider) { create(:provider, name: "London Provider", ukprn: "10052837") }
    let(:guildford_provider) { create(:provider, name: "Guildford Provider", ukprn: "222222") }
    let(:attributes) { { csv_upload: valid_file } }
    let(:valid_file) do
      ActionDispatch::Http::UploadedFile.new({
                                               filename: "valid.csv",
                                               type: "text/csv",
                                               tempfile: File.open(
                                                 "spec/fixtures/importers/provider_users.csv",
                                                 )
                                             })
    end

    before do
      london_provider
      guildford_provider
    end

    it "reads a given CSV and assigns the content to the csv_content attribute" do
      expect(step.csv_content).to eq(
                                    "ukprn,first_name,last_name,email_address\n" \
                                      "10052837,Jeff,Barnes,j.barnes@example.com\n" \
                                      "10032194,Jeff,Barnes,j.barnes@example.com\n" \
                                      "10032194,James,Hill,j.hill@example.com\n" \
                                      "10064216,Sarah,Smith,\n",
                                    )
    end
  end

  describe "#csv" do
    subject(:csv) { step.csv }

    let(:csv_content) do
      "ukprn,first_name,last_name,email_address\n" \
        "10052837,Joe,Bloggs,joe_bloggs@example.com\n" \
        "222222,Sue,Doe,sue_doe@example.com\n" \
        ""
    end
    let(:attributes) { { csv_content: } }

    it "converts the csv content into a CSV record" do
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to match_array(
                               %w[ukprn first_name last_name email_address],
                               )
      expect(csv.count).to eq(2)

      expect(csv[0]).to be_a(CSV::Row)
      expect(csv[0].to_h).to eq({
                                  "ukprn" => "10052837",
                                  "first_name" => "Joe",
                                  "last_name" => "Bloggs",
                                  "email_address" => "joe_bloggs@example.com"
                                })

      expect(csv[1]).to be_a(CSV::Row)
      expect(csv[1].to_h).to eq({
                                  "ukprn" => "222222",
                                  "first_name" => "Sue",
                                  "last_name" => "Doe",
                                  "email_address" => "sue_doe@example.com"
                                })
    end
  end
end
