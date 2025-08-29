require "rails_helper"

describe BroadcastPlacementRequests do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  describe "#call" do
    let(:school)  { create(:school) }
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
      create_list(:placement_request, 5, school: school, requested_by:)
    end

    before do
      placement_preference
      placement_requests

      allow(SchoolMailer).to receive(:placement_request_notification)
        .with(school)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
    end

    it "sends email notifications to each school with not sent placement requests" do
      expect { described_class.call }.to change(PlacementRequest.sent, :count).from(0).to(5)
      expect(SchoolMailer).to have_received(:placement_request_notification).with(school).once
    end
  end
end
