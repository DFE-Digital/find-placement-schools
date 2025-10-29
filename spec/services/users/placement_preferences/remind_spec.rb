require "rails_helper"

RSpec.describe Users::PlacementPreferences::Remind do
  subject(:user_placement_preference_remind_service) { described_class.call }

  it_behaves_like "a service object"

  let(:school) { create(:school) }
  let(:user) { create(:user, last_signed_in_at:, organisations: [ school ]) }

  describe "#call" do
    context "when the school has placement preferences" do
      context "when the user signed in 2 weeks ago" do
        let(:last_signed_in_at) { 2.weeks.ago }
        let(:placement_preference) do
          create(
            :placement_preference,
            created_by: user,
            organisation: school,
            academic_year: AcademicYear.next,
          )
        end

        before do
          placement_preference
        end

        it "does not send an email to the school user" do
          expect { user_placement_preference_remind_service }.not_to enqueue_mail(
            School::UserMailer,
            :placement_preferences_reminder_notification,
          )
        end
      end
    end

    context "when the school does not have a placement preferences" do
      before { user }

      context "when the user signed in less than 2 weeks ago" do
        let(:last_signed_in_at) { 1.week.ago }

        it "does not send an email to the school user" do
          expect { user_placement_preference_remind_service }.not_to enqueue_mail(
            School::UserMailer,
            :placement_preferences_reminder_notification,
          )
        end
      end

      context "when the user signed in exactly 2 weeks ago" do
        let(:last_signed_in_at) { 2.week.ago }

        it "does not send an email to the school user" do
          expect { user_placement_preference_remind_service }.to enqueue_mail(
            School::UserMailer,
            :placement_preferences_reminder_notification,
          )
        end
      end

      context "when the user was signed in more than 2 weeks ago" do
        context "when the user was signed in less that a month and 2 weeks ago" do
          let(:last_signed_in_at) { 2.week.ago - 1.week }

          it "does not send an email to the user" do
            expect { user_placement_preference_remind_service }.not_to enqueue_mail(
              School::UserMailer,
              :placement_preferences_reminder_notification,
            )
          end
        end

        context "when the user was signed in exactly a month and 2 weeks ago" do
          let(:last_signed_in_at) { 2.week.ago - 1.month }

          it "sends an email to the user" do
            expect { user_placement_preference_remind_service }.to enqueue_mail(
              School::UserMailer,
              :placement_preferences_reminder_notification,
            )
          end
        end

        context "when the user was signed in more than a month and 2 weeks ago" do
          context "when the user was signed in less that 2 months and 2 weeks ago" do
            let(:last_signed_in_at) { 1.month.ago - 3.week }

            it "does not send an email to the user" do
              expect { user_placement_preference_remind_service }.not_to enqueue_mail(
                School::UserMailer,
                :placement_preferences_reminder_notification,
              )
            end
          end

          context "when the user was signed in exactly 2 months and 2 weeks ago" do
            let(:last_signed_in_at) { 2.week.ago - 2.month }

            it "sends an email to the user" do
              expect { user_placement_preference_remind_service }.to enqueue_mail(
                School::UserMailer,
                :placement_preferences_reminder_notification,
              )
            end
          end

          context "when the user was signed in more than 2 month and 2 weeks ago" do
            let(:last_signed_in_at) { 3.months.ago }

            it "does not send an email to the user" do
              expect { user_placement_preference_remind_service }.not_to enqueue_mail(
                School::UserMailer,
                :placement_preferences_reminder_notification,
              )
            end
          end
        end
      end
    end
  end
end
