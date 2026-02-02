require "rails_helper"

RSpec.describe EditHostingInterestWizard do
  subject(:wizard) do
    described_class.new(placement_preference:, state:, params:, school:, current_step:, current_user:)
  end

  let(:school) { create(:school) }
  let(:academic_year) { AcademicYear.current }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:current_user) { create(:user) }
  let(:placement_preference) { create(:placement_preference, organisation: school, placement_details:, academic_year:) }
  let(:placement_details) do
    {
      "phase" => { "phases" => %w[primary secondary send] },
      "appetite" => { "appetite" => "actively_looking" },
      "school_contact" => { "first_name" => "Joe", "last_name" => "Bloggs", "email_address" => "b@email.com" },
      "note_to_providers" => { "note" => "Note to providers" },
      "check_your_answers" => nil,
      "key_stage_selection" => { "key_stages" => %w[key_stage_1 key_stage_2] },
      "year_group_selection" => { "year_groups" => %w[reception year_1] },
      "secondary_subject_selection" => { "subject_ids" => %w[123456789 987654321] },
      "secondary_child_subject_selection_123456789" => {
        "selection_id" => "123456789",
        "selection_number" => "123456789",
        "child_subject_ids" => %w[abcdef123456 123456abcdef],
        "parent_subject_id" => "123456789"
      }
    }
  end

  describe "setup_state" do
    subject(:setup_state) { wizard.setup_state }

    it "assigns the placement details to the state attribute" do
      setup_state
      expect(placement_details).to eq({
        "phase" => { "phases" => %w[primary secondary send] },
        "appetite" => { "appetite" => "actively_looking" },
        "school_contact" => { "first_name" => "Joe", "last_name" => "Bloggs", "email_address" => "b@email.com" },
        "note_to_providers" => { "note" => "Note to providers" },
        "check_your_answers" => nil,
        "key_stage_selection" => { "key_stages" => %w[key_stage_1 key_stage_2] },
        "year_group_selection" => { "year_groups" => %w[reception year_1] },
        "secondary_subject_selection" => { "subject_ids" => %w[123456789 987654321] },
        "secondary_child_subject_selection_123456789" => {
          "selection_id" => "123456789",
          "selection_number" => "123456789",
          "child_subject_ids" => %w[abcdef123456 123456abcdef],
          "parent_subject_id" => "123456789"
        }
      })
    end
  end
end
