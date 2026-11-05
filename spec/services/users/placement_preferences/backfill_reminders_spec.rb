require "rails_helper"

RSpec.describe Users::PlacementPreferences::BackfillReminders do
  subject(:backfill) { described_class.call }

  around do |example|
    # The 2026 to 2027 academic year started on 1 September, so the old daily
    # schedule is replayed from then until today.
    travel_to(Time.zone.local(2026, 11, 5, 12)) { example.run }
  end

  let(:school) { create(:school) }
  let(:last_signed_in_at) { nil }
  let(:user) { create(:user, last_signed_in_at:, organisations: [ school ]) }

  def reminder_days
    PlacementPreferenceReminder
      .where(user:, organisation: school, academic_year: AcademicYear.next)
      .order(:created_at)
      .pluck(:created_at)
      .map(&:to_date)
  end

  it_behaves_like "a service object"

  before do
    # Memberships pre-date the replayed run days.
    user.user_memberships.update_all(created_at: Time.zone.local(2026, 1, 1))
  end

  context "when all three old reminders were sent since the academic year started" do
    let(:last_signed_in_at) { Time.zone.local(2026, 8, 20, 9) }

    it "records all three on the days they were sent" do
      backfill

      expect(reminder_days).to eq([ Date.new(2026, 9, 3), Date.new(2026, 10, 4), Date.new(2026, 11, 3) ])
      expect(PlacementPreferenceReminder.first.created_at.hour).to eq(10)
    end

    it "stops the user being reminded again" do
      backfill

      travel_to(Time.zone.local(2026, 12, 1, 10))

      expect { Users::PlacementPreferences::Remind.call }.not_to have_enqueued_mail(
        School::UserMailer,
        :placement_preferences_reminder_notification,
      )
    end
  end

  context "when the first old reminder was sent before the academic year started" do
    let(:last_signed_in_at) { Time.zone.local(2026, 8, 10, 9) }

    it "records only the reminders sent since then" do
      backfill

      expect(reminder_days).to eq([ Date.new(2026, 9, 24), Date.new(2026, 10, 24) ])
    end

    it "leaves one more reminder to send" do
      backfill

      travel_to(Time.zone.local(2026, 12, 1, 10))

      expect { Users::PlacementPreferences::Remind.call }.to have_enqueued_mail(
        School::UserMailer,
        :placement_preferences_reminder_notification,
      ).with(user, school, AcademicYear.next)
    end
  end

  context "when some old reminders are still in the future" do
    let(:last_signed_in_at) { Time.zone.local(2026, 9, 1, 9) }

    it "records only the reminders already sent" do
      backfill

      expect(reminder_days).to eq([ Date.new(2026, 9, 15), Date.new(2026, 10, 15) ])
    end
  end

  context "when the user signed in less than 2 weeks ago" do
    let(:last_signed_in_at) { Time.zone.local(2026, 10, 28, 9) }

    it "records nothing" do
      expect { backfill }.not_to change(PlacementPreferenceReminder, :count)
    end
  end

  context "when all old reminders were sent before the academic year started" do
    let(:last_signed_in_at) { Time.zone.local(2026, 6, 1, 9) }

    it "records nothing" do
      expect { backfill }.not_to change(PlacementPreferenceReminder, :count)
    end
  end

  context "when the user has never signed in" do
    let(:last_signed_in_at) { nil }

    it "records nothing" do
      expect { backfill }.not_to change(PlacementPreferenceReminder, :count)
    end
  end

  context "when the school has a preference for the next academic year" do
    let(:last_signed_in_at) { Time.zone.local(2026, 8, 20, 9) }

    before do
      create(:placement_preference, created_by: user, organisation: school, academic_year: AcademicYear.next)
    end

    it "records nothing" do
      expect { backfill }.not_to change(PlacementPreferenceReminder, :count)
    end
  end

  context "when the user joined the school after an old reminder day" do
    let(:last_signed_in_at) { Time.zone.local(2026, 8, 20, 9) }

    before { user.user_memberships.update_all(created_at: Time.zone.local(2026, 10, 1)) }

    it "records only the reminders sent after they joined" do
      backfill

      expect(reminder_days).to eq([ Date.new(2026, 10, 4), Date.new(2026, 11, 3) ])
    end
  end

  context "when run twice" do
    let(:last_signed_in_at) { Time.zone.local(2026, 8, 20, 9) }

    it "does not record the reminders twice" do
      described_class.call

      expect { backfill }.not_to change(PlacementPreferenceReminder, :count)
    end
  end
end
