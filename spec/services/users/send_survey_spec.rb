require "rails_helper"

RSpec.describe Users::SendSurvey do
  subject(:send_survey) { described_class.call(user:, organisation:) }

  it_behaves_like "a service object" do
    let(:params) { { user: create(:user), organisation: create(:school) } }
  end

  describe "call" do
    describe "when the organisation is a school" do
      let(:organisation) { build(:school) }
      let(:user) { create(:user, organisations: [ organisation ], survey_sent_at:) }

      context "when the user has not received a survey" do
        let(:survey_sent_at) { nil }

        it "calls mailer with correct params" do
          expect { send_survey }.to have_enqueued_mail(School::UserMailer, :user_feedback_request_notification).with(user)
        end
      end

      context "when the user has already received a survey" do
        let(:survey_sent_at) { Time.zone.now }

        it "does not call the mailer" do
          expect { send_survey }.not_to have_enqueued_mail(School::UserMailer, :user_feedback_request_notification)
        end
      end
    end

    describe "when the organisation is a provider" do
      let(:organisation) { build(:provider) }
      let(:user) { create(:user, organisations: [ organisation ], survey_sent_at:) }

      context "when the user has not received a survey" do
        let(:survey_sent_at) { nil }

        it "calls mailer with correct params" do
          expect { send_survey }.to have_enqueued_mail(Provider::UserMailer, :user_feedback_request_notification).with(user)
        end
      end

      context "when the user has already received a survey" do
        let(:survey_sent_at) { Time.zone.now }

        it "does not call the mailer" do
          expect { send_survey }.not_to have_enqueued_mail(Provider::UserMailer, :user_feedback_request_notification)
        end
      end
    end
  end
end
