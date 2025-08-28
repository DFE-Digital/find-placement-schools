require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#placement_request_notification" do
    subject(:placement_request_notification) do
      described_class.placement_request_notification(school)
    end

    let(:school)  { build(:school) }
    let(:placement_preference) do
      create(:placement_preference, organisation: school, placement_details:)
    end
    let(:placement_details) do
      {
        "appetite" => { "appetite" => "actively_looking" },
        "phase" => { "phases" => %w[primary] },
        "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
        "school_contact" => {
          "first_name" => "Joe",
          "last_name" => "Bloggs",
          "email_address" => "joe_bloggs@example.com"
        }
      }
    end
    let(:requested_by) { build(:user, email_address: "jane_doe@example.com") }
    let(:placement_requests) do
      create_list(:placement_request, 1, school: school, requested_by:)
    end

    before do
      placement_requests
      placement_preference
    end

    it "sends an email to school contact regarding providers placement requests" do
      expect(placement_request_notification.to).to contain_exactly("joe_bloggs@example.com")
      expect(placement_request_notification.subject).to eq("Help hosting ITT placements")
      expect(placement_request_notification.body).to have_content <<~EMAIL
        Hello Joe Bloggs

        The following providers require urgent assistance finding placements to host ITT trainees.
        If you are able to host a placement please contact the provider as soon as possible.

          - #{placement_requests.first.provider.name} (jane_doe@example.com)
      EMAIL
    end
  end
end
