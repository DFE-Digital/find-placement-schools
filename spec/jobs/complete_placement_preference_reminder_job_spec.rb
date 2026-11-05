require "rails_helper"

RSpec.describe CompletePlacementPreferenceReminderJob, type: :job do
  describe ".send_day?" do
    it "is true on the 1st of the month when it is a weekday" do
      expect(described_class.send_day?(Date.new(2026, 12, 1))).to be(true) # Tuesday
    end

    it "is false on other weekdays" do
      expect(described_class.send_day?(Date.new(2026, 12, 2))).to be(false)
    end

    context "when the 1st is a Saturday" do
      it "is the following Monday, the 3rd" do
        expect(described_class.send_day?(Date.new(2026, 8, 1))).to be(false)
        expect(described_class.send_day?(Date.new(2026, 8, 3))).to be(true)
      end
    end

    context "when the 1st is a Sunday" do
      it "is the following Monday, the 2nd" do
        expect(described_class.send_day?(Date.new(2026, 11, 1))).to be(false)
        expect(described_class.send_day?(Date.new(2026, 11, 2))).to be(true)
        expect(described_class.send_day?(Date.new(2026, 11, 3))).to be(false)
      end
    end
  end

  describe "#perform" do
    before do
      allow(Users::PlacementPreferences::Remind).to receive(:call).and_return(true)
    end

    it "calls the Users::PlacementPreferences::Remind service on the send day" do
      travel_to(Time.zone.local(2026, 12, 1, 10)) { described_class.perform_now }
      expect(Users::PlacementPreferences::Remind).to have_received(:call).once
    end

    it "does nothing on other days" do
      travel_to(Time.zone.local(2026, 12, 2, 10)) { described_class.perform_now }
      expect(Users::PlacementPreferences::Remind).not_to have_received(:call)
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
