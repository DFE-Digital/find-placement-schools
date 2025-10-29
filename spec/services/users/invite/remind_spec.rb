require "rails_helper"

RSpec.describe Users::Invite::Remind do
  subject(:user_invite_remind_service) { described_class.call }

  it_behaves_like "a service object"

  let(:user) { create(:user, created_at:) }

  describe "call" do
    before { user }

    context "when the user was created less than 2 weeks ago" do
      let(:created_at) { 1.week.ago }

      it "does not send an email to the user" do
        expect { user_invite_remind_service }.not_to enqueue_mail(
           School::UserMailer,
          :user_membership_sign_in_reminder_notification,
        )
      end
    end

    context "when the user was created exactly 2 weeks ago" do
      let(:created_at) { 2.week.ago }

      it "does send an email to the user" do
        expect { user_invite_remind_service }.to enqueue_mail(
          School::UserMailer,
          :user_membership_sign_in_reminder_notification,
        )
      end
    end

    context "when the user was created more than 2 weeks ago" do
      context "when the user was created less that a month and 2 weeks ago" do
        let(:created_at) { 2.week.ago - 1.week }

        it "does not send an email to the user" do
          expect { user_invite_remind_service }.not_to enqueue_mail(
            School::UserMailer,
            :user_membership_sign_in_reminder_notification,
          )
        end
      end

      context "when the user was created exactly a month and 2 weeks ago" do
        let(:created_at) { 2.week.ago - 1.month }

        it "sends an email to the user" do
          expect { user_invite_remind_service }.to enqueue_mail(
            School::UserMailer,
            :user_membership_sign_in_reminder_notification,
          )
        end
      end

      context "when the user was created more than a month and 2 weeks ago" do
        context "when the user was created less that 2 months and 2 weeks ago" do
          let(:created_at) { 1.month.ago - 3.week }

          it "does not send an email to the user" do
            expect { user_invite_remind_service }.not_to enqueue_mail(
              School::UserMailer,
              :user_membership_sign_in_reminder_notification,
            )
          end
        end

        context "when the user was created exactly 2 months and 2 weeks ago" do
          let(:created_at) { 2.week.ago - 2.month }

          it "sends an email to the user" do
            expect { user_invite_remind_service }.to enqueue_mail(
              School::UserMailer,
              :user_membership_sign_in_reminder_notification,
            )
          end
        end

        context "when the user was created more than 2 month and 2 weeks ago" do
          let(:created_at) { 3.months.ago }

          it "does not send an email to the user" do
            expect { user_invite_remind_service }.not_to enqueue_mail(
              School::UserMailer,
              :user_membership_sign_in_reminder_notification,
            )
          end
        end
      end
    end
  end
end
