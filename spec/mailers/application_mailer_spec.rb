require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
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
end
