require "rails_helper"

RSpec.describe NotifyRateLimiterJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let(:wait_time) { 1.minute }
    let(:batch) { create_list(:school, 5) }
    let(:mailer) { "SchoolMailer" }
    let(:mailer_method) { :placement_request_notification }
    let(:mailer_args) { %w[arg1] }
    let(:mailer_kwargs) { { name: "Bob" } }

    it "enqueues a mailer job for each record with wait time", :aggregate_failures do
      expect {
        described_class.perform_now(wait_time, batch, mailer, mailer_method)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(batch.size).times
    end

    context "when the mailer method has additional arguments" do
      let(:batch) { create_list(:school, 1) }

      it "enqueues a mailer job with the correct arguments", :aggregate_failures do
        described_class.perform_now(wait_time, batch, mailer, mailer_method, mailer_args, mailer_kwargs)

        batch.each do |item|
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.with(
            mailer.to_s,
            mailer_method.to_s,
            "deliver_now",
            { args: [ item, "arg1", mailer_kwargs ] },
            )
        end
      end
    end
  end
end
