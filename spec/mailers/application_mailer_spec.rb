require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  include ActiveJob::TestHelper
  class TestApplicationMailer < ApplicationMailer
    def sample_email
      notify_email to: "test@example.com", subject: "Test subject", body: "Test body"
    end
  end

  describe "#environment_prefix" do
    context "when HostingEnvironment.env is production" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "returns an empty string" do
        expect(subject.send(:environment_prefix)).to eq("")
      end
    end

    context "when HostingEnvironment.env is test" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("test")
      end

      it "returns an empty string" do
        expect(subject.send(:environment_prefix)).to eq("")
      end
    end

    context "when HostingEnvironment.env is development" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("development")
      end

      it "returns the environment name in brackets" do
        expect(subject.send(:environment_prefix)).to eq("[DEVELOPMENT] ")
      end
    end

    context "when HostingEnvironment.env is staging" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "returns the environment name in brackets" do
        expect(subject.send(:environment_prefix)).to eq("[STAGING] ")
      end
    end
  end

  describe "#protocol" do
    subject(:application_mailer) { described_class.new }

    context "when Rails environment is production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it 'returns "https"' do
        expect(application_mailer.send(:protocol)).to eq("https")
      end
    end

    context "when Rails environment is not production" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it 'returns "http"' do
        expect(application_mailer.send(:protocol)).to eq("http")
      end
    end
  end

  describe "delivery scheduling" do
    subject(:message_delivery) { TestApplicationMailer.sample_email }

    let(:next_working_day) { Date.parse("2026-03-17") }

    before do
      allow(BankHoliday).to receive(:is_bank_holiday?).with(Date.current).and_return(is_bank_holiday)
      allow(BankHoliday).to receive(:next_working_day).with(Date.current).and_return(next_working_day)
      clear_enqueued_jobs
    end

    context "when today is not a bank holiday" do
      let(:is_bank_holiday) { false }

      it "enqueues immediately with no wait_until override" do
        expect {
          message_delivery.deliver_later
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "TestApplicationMailer",
          "sample_email",
          "deliver_now",
          args: [],
          )
      end
    end

    context "when today is a bank holiday" do
      let(:is_bank_holiday) { true }

      it "reschedules the email to the next working day" do
        expect {
          message_delivery.deliver_later
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "TestApplicationMailer",
          "sample_email",
          "deliver_now",
          args: [],
          ).at(next_working_day.beginning_of_day)
      end
    end
  end
end
