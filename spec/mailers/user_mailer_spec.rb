require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#placement_preferences_notification" do
    let!(:user) { create(:user, email_address: "test@sample.com", first_name: "Joe") }
    subject(:placement_preferences_notification) { described_class.placement_preferences_notification(user) }

    let!(:current_year) { create(:academic_year, :current) }

    let!(:eligible_school) { create(:school, name: "Shelbyville School") }

    let!(:user_membership_to_eligible_school) do
      create(:user_membership, user: user, organisation: eligible_school)
    end

    let!(:ineligible_school) { create(:school, name: "Springfield High") }
    let!(:ineligible_placement_preference) do
      create(:placement_preference, organisation: ineligible_school, academic_year: current_year, created_by: create(:user))
    end

    it "sends the placement preferences notification email" do
      expect(placement_preferences_notification.to).to contain_exactly("test@sample.com")
      expect(placement_preferences_notification.subject).to eq("Please update your schools placement preferences")
      expect(placement_preferences_notification.body.to_s.squish).to eq(<<~EMAIL.squish)
        Joe,

        The following schools:
        Shelbyville School

        Have no placement preferences. Please update their placement preferences.

        This notification will be sent once a month.
      EMAIL
    end
  end
end
