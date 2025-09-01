require "rails_helper"

RSpec.describe PlacementPreferencesReminderJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let!(:current_year) { create(:academic_year, :current) }
    let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(AcademicYear).to receive(:current).and_return(current_year)
      allow(UserMailer).to receive(:placement_preferences_notification).and_return(mailer_double)
    end

    context "when there are no eligible users" do
      let!(:school_with_pref) { create(:school) }
      let!(:placement_preference) { create(:placement_preference, organisation: school_with_pref, academic_year: current_year) }
      let!(:user_in_ineligible_school) { create(:user) }
      let!(:membership) { create(:user_membership, user: user_in_ineligible_school, organisation: school_with_pref) }

      it "does not call the mailer" do
        described_class.perform_now
        expect(UserMailer).not_to have_received(:placement_preferences_notification)
      end
    end

    context "when there are eligible users" do
      let!(:eligible_school) { create(:school) }
      let!(:eligible_user_1) { create(:user) }
      let!(:eligible_user_2) { create(:user) }

      let!(:user_1_membership_to_eligible_school) { create(:user_membership, user: eligible_user_1, organisation: eligible_school) }
      let!(:user_2_membership_to_eligible_school) { create(:user_membership, user: eligible_user_2, organisation: eligible_school) }

      let!(:ineligible_school) { create(:school) }
      let!(:placement_preference) { create(:placement_preference, organisation: ineligible_school, academic_year: current_year) }
      let!(:ineligible_user) { create(:user) }
      let!(:m3) { create(:user_membership, user: ineligible_user, organisation: ineligible_school) }

      it "calls the mailer once for each eligible user id" do
        described_class.perform_now

        expect(UserMailer).to have_received(:placement_preferences_notification)
          .with(eligible_user_1.id).once
        expect(UserMailer).to have_received(:placement_preferences_notification)
          .with(eligible_user_2.id).once
        expect(UserMailer).not_to have_received(:placement_preferences_notification)
          .with(ineligible_user.id)
      end
    end

    it "enqueues the job on the mailers queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue("mailers")
    end
  end
end
