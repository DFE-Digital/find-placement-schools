require "rails_helper"

RSpec.describe Users::PlacementPreferences::Remind do
  subject(:user_placement_preference_remind_service) { described_class.call }

  it_behaves_like "a service object"

  let(:school) { create(:school) }
  let(:last_signed_in_at) { 2.weeks.ago }
  let(:user) { create(:user, last_signed_in_at:, organisations: [ school ]) }

  def expect_reminder
    expect { user_placement_preference_remind_service }.to have_enqueued_mail(
      School::UserMailer,
      :placement_preferences_reminder_notification,
    ).with(user, school, AcademicYear.next).exactly(:once)
  end

  def expect_no_reminder
    expect { user_placement_preference_remind_service }.not_to have_enqueued_mail(
      School::UserMailer,
      :placement_preferences_reminder_notification,
    )
  end

  describe "#call" do
    context "when the school has a placement preference for the next academic year" do
      before do
        create(:placement_preference, created_by: user, organisation: school, academic_year: AcademicYear.next)
      end

      it "does not send an email to the school user" do
        expect_no_reminder
      end
    end

    context "when the school does not have a placement preference" do
      before { user }

      context "when the user signed in less than 2 weeks ago" do
        let(:last_signed_in_at) { 13.days.ago }

        it "does not send an email to the school user" do
          expect_no_reminder
        end
      end

      context "when the user has never signed in" do
        let(:last_signed_in_at) { nil }

        it "does not send an email to the school user" do
          expect_no_reminder
        end
      end

      context "when the user signed in 2 weeks ago" do
        it "sends an email to the user" do
          expect_reminder
        end

        it "records the reminder" do
          expect { user_placement_preference_remind_service }.to change(PlacementPreferenceReminder, :count).by(1)
          expect(PlacementPreferenceReminder.last).to have_attributes(
            user:,
            organisation: school,
            academic_year: AcademicYear.next,
          )
        end
      end

      context "when the user signed in a long time ago" do
        let(:last_signed_in_at) { 6.months.ago }

        it "sends an email to the user" do
          expect_reminder
        end
      end

      context "when the user has already been sent fewer than 3 reminders" do
        before do
          create(:placement_preference_reminder, user:, organisation: school, created_at: 2.months.ago)
          create(:placement_preference_reminder, user:, organisation: school, created_at: 1.month.ago)
        end

        it "sends an email to the user" do
          expect_reminder
        end
      end

      context "when the user has already been sent 3 reminders" do
        before do
          3.times do |i|
            create(:placement_preference_reminder, user:, organisation: school, created_at: (i + 1).months.ago)
          end
        end

        it "does not send an email to the user" do
          expect_no_reminder
        end

        context "when the user signs in again" do
          let(:last_signed_in_at) { 3.weeks.ago }

          it "still does not send an email to the user" do
            expect_no_reminder
          end
        end
      end

      context "when the 3 reminders were for a previous academic year" do
        before do
          3.times do
            create(:placement_preference_reminder, user:, organisation: school, academic_year: AcademicYear.current)
          end
        end

        it "sends an email to the user" do
          expect_reminder
        end
      end

      context "when the user was reminded in the last 3 weeks" do
        before do
          create(:placement_preference_reminder, user:, organisation: school, created_at: 20.days.ago)
        end

        it "does not send an email to the user" do
          expect_no_reminder
        end
      end

      context "when the email cannot be enqueued" do
        let(:mailer_double) { double }

        before do
          allow(School::UserMailer).to receive(:placement_preferences_reminder_notification).and_return(mailer_double)
          allow(mailer_double).to receive(:deliver_later).and_raise(ActiveJob::EnqueueError)
        end

        it "does not record the reminder" do
          expect { user_placement_preference_remind_service }.to raise_error(ActiveJob::EnqueueError)
          expect(PlacementPreferenceReminder.count).to eq(0)
        end
      end

      context "when the membership is no longer eligible by the time it is processed" do
        before do
          allow(UserMembership).to receive(:transaction).and_wrap_original do |original, &block|
            create(:placement_preference_reminder, user:, organisation: school)
            original.call(&block)
          end
        end

        it "does not send an email to the user" do
          expect_no_reminder
          expect(PlacementPreferenceReminder.count).to eq(1)
        end
      end

      context "when the service is run twice" do
        it "only sends one email" do
          described_class.call

          expect_no_reminder
        end
      end

      context "when the service is run every month and the user keeps signing in" do
        it "sends at most 3 emails" do
          # Stay within one academic year so AcademicYear.next does not change.
          start_of_academic_year = AcademicYear.current.starts_on.beginning_of_day

          5.times do |month|
            travel_to(start_of_academic_year + month.months) do
              user.update!(last_signed_in_at: 2.weeks.ago)
              described_class.call
            end
          end

          expect(PlacementPreferenceReminder.where(user:, organisation: school).count).to eq(3)
        end
      end
    end

    context "when the school only has a preference for the current academic year" do
      before do
        create(:placement_preference, created_by: user, organisation: school, academic_year: AcademicYear.current)
      end

      it "sends a reminder for the next academic year" do
        expect_reminder
      end
    end

    context "when the user belongs to several schools" do
      let(:other_school) { create(:school) }
      let(:user) { create(:user, last_signed_in_at:, organisations: [ school, other_school ]) }

      before { user }

      context "when only one school is missing a preference" do
        before do
          create(:placement_preference, created_by: user, organisation: other_school, academic_year: AcademicYear.next)
        end

        it "reminds the user about the school missing a preference only" do
          expect_reminder
        end
      end

      context "when both schools are missing a preference" do
        it "sends a reminder for each school" do
          expect { user_placement_preference_remind_service }.to have_enqueued_mail(
            School::UserMailer,
            :placement_preferences_reminder_notification,
          ).twice
        end
      end

      context "when the user has had 3 reminders for one school only" do
        before do
          3.times do |i|
            create(:placement_preference_reminder, user:, organisation: other_school, created_at: (i + 1).months.ago)
          end
        end

        it "still reminds the user about the other school" do
          expect_reminder
        end
      end
    end

    context "when there are more than 100 users to remind" do
      150.times do
        let!("user_#{_1}") do
          create(:user,
            last_signed_in_at: 2.weeks.ago,
            organisations: [ create(:school) ])
        end
      end

      let(:mailer_double) { double }

      before do
        allow(School::UserMailer).to receive(:placement_preferences_reminder_notification).and_return(mailer_double)
      end

      it "sends emails to all users in batches" do
        expect(mailer_double).to receive(:deliver_later).with(wait: 0.minutes).exactly(100).times
        expect(mailer_double).to receive(:deliver_later).with(wait: 1.minute).exactly(50).times
        user_placement_preference_remind_service
      end
    end
  end
end
