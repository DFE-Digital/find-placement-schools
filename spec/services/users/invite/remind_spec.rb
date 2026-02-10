require "rails_helper"

RSpec.describe Users::Invite::Remind do
  subject(:user_invite_remind_service) { described_class.call }

  it_behaves_like "a service object"

  let(:user) { build(:user, created_at:) }
  let(:organisation) { build(:school) }
  let(:membership) { create(:user_membership, user:, organisation:) }

  describe "call" do
    before { membership }

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
      let(:created_at) { 2.weeks.ago }

      it "does send an email to the user" do
        expect { user_invite_remind_service }.to enqueue_mail(
          School::UserMailer,
          :user_membership_sign_in_reminder_notification,
        )
      end
    end

    context "when the user was created more than 2 weeks ago" do
      context "when the user was created less that a month and 2 weeks ago" do
        let(:created_at) { 2.weeks.ago - 1.week }

        it "does not send an email to the user" do
          expect { user_invite_remind_service }.not_to enqueue_mail(
            School::UserMailer,
            :user_membership_sign_in_reminder_notification,
          )
        end
      end

      context "when the user was created exactly a month and 2 weeks ago" do
        let(:created_at) { 2.weeks.ago - 1.month }

        it "sends an email to the user" do
          expect { user_invite_remind_service }.to enqueue_mail(
            School::UserMailer,
            :user_membership_sign_in_reminder_notification,
          )
        end
      end

      context "when the user was created more than a month and 2 weeks ago" do
        context "when the user was created less that 2 months and 2 weeks ago" do
          let(:created_at) { 1.month.ago - 3.weeks }

          it "does not send an email to the user" do
            expect { user_invite_remind_service }.not_to enqueue_mail(
              School::UserMailer,
              :user_membership_sign_in_reminder_notification,
            )
          end
        end

        context "when the user was created exactly 2 months and 2 weeks ago" do
          let(:created_at) { 2.weeks.ago - 2.months }

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

    context "when there are more than 100 users to remind" do
      let(:created_at) { 2.weeks.ago }
      let!(:users) { create_list(:user, 149, created_at:, schools: [ organisation ]) }
      let(:mailer_double) { double }

      before do
        allow(School::UserMailer).to receive(:user_membership_sign_in_reminder_notification).and_return(mailer_double)
      end

      it "sends emails to all users in batches" do
        expect(mailer_double).to receive(:deliver_later).with(wait: 0.minutes).exactly(100).times
        expect(mailer_double).to receive(:deliver_later).with(wait: 1.minute).exactly(50).times
        user_invite_remind_service
      end
    end

    context "when the school has a preference for the next academic year" do
      let(:created_at) { 2.weeks.ago }

      it "does not send an email to the user" do
        create(:placement_preference, organisation:, academic_year: AcademicYear.next)
        expect { user_invite_remind_service }.not_to enqueue_mail(
          School::UserMailer,
          :user_membership_sign_in_reminder_notification,
        )
      end
    end
  end
end
