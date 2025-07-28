require "rails_helper"

RSpec.describe PublishTeacherTraining::Subject::SyncAllJob, type: :job do
  describe "#perform" do
    context "when the response contains only valid subject data" do
      before do
        success_stub_request
      end

      it "creates a subject record per Subject returned by the Publish API" do
        expect { described_class.perform_now }.to change(PlacementSubject.primary, :count)
        .by(2).and change(
          PlacementSubject.secondary, :count
        ).by(3)

        expect(PlacementSubject.primary.pluck(:name)).to contain_exactly("Primary", "Primary with English")

        expect(PlacementSubject.secondary.pluck(:name)).to contain_exactly("Art and design", "Science", "French")
      end

      context "when a subject already exists" do
        it "only creates a subject for each not pre-existing subject" do
          create(:placement_subject, :primary, name: "Primary", code: "00")

          expect {
            described_class.perform_now
          }.to change(PlacementSubject, :count).by(4)
        end
      end
    end

    context "when the response contains an invalid subject data" do
      before do
        failure_stub_request
      end

      it "only creates a the valid subject" do
        expect { described_class.perform_now }.to change(PlacementSubject.primary, :count).by(1)

        expect(PlacementSubject.primary.pluck(:name)).to contain_exactly("Primary with English")
      end
    end
  end

  private

  def success_stub_request
    stub_request(
      :get,
      "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/subject_areas?include=subjects",
    ).to_return(
      status: 200,
      body: response_body.to_json,
    )
  end

  def failure_stub_request
    stub_request(
      :get,
      "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/subject_areas?include=subjects",
    ).to_return(
      status: 200,
      body: invalid_response_body.to_json,
    )
  end

  def invalid_response_body
    {
      "data" => [
        {
          "id" => "PrimarySubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "1"
                },
                {
                  "type" => "subjects",
                  "id" => "2"
                }
              ]
            }
          }
        }
      ],
      "included" => [
        {
          "id" => "1",
          "attributes" => {
            "name" => "",
            "code" => "00"
          }
        },
        {
          "id" => "2",
          "attributes" => {
            "name" => "Primary with English",
            "code" => "01"
          }
        }
      ]
    }
  end

  def response_body
    {
      "data" => [
        {
          "id" => "PrimarySubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "1"
                },
                {
                  "type" => "subjects",
                  "id" => "2"
                }
              ]
            }
          }
        },
        {
          "id" => "SecondarySubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "3"
                },
                {
                  "type" => "subjects",
                  "id" => "4"
                }
              ]
            }
          }
        },
        {
          "id" => "ModernLanguagesSubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "5"
                }
              ]
            }
          }
        },
        {
          # FurtherEducationSubject is not a valid subject area
          "id" => "FurtherEducationSubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "6"
                }
              ]
            }
          }
        }
      ],
      "included" => [
        {
          "id" => "1",
          "attributes" => {
            "name" => "Primary",
            "code" => "00"
          }
        },
        {
          "id" => "2",
          "attributes" => {
            "name" => "Primary with English",
            "code" => "01"
          }
        },
        {
          "id" => "3",
          "attributes" => {
            "name" => "Art and design",
            "code" => "W1"
          }
        },
        {
          "id" => "4",
          "type" => "subjects",
          "attributes" => {
            "name" => "Science",
            "code" => "F0"
          }
        },
        {
          "id" => "5",
          "attributes" => {
            "name" => "French",
            "code" => "15"
          }
        },
        {
          # Further education is not a valid subject
          "id" => "6",
          "attributes" => {
            "name" => "Further education",
            "code" => "41"
          }
        }
      ]
    }
  end
end
