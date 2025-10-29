require "rails_helper"

RSpec.describe UserSignInReminderJob, type: :job do
  describe "#perform" do
    before do
      allow(Users::Invite::Remind).to receive(:call).and_return(true)
    end

    it "calls the Users::PlacementPreferences::Remind service" do
      described_class.perform_now
      expect(Users::Invite::Remind).to have_received(:call).once
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
