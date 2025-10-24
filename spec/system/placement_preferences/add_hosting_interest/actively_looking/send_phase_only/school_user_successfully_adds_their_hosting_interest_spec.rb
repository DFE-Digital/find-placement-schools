require "rails_helper"

RSpec.describe "School user successfully adds their hosting interest", type: :system do
  scenario do
    given_academic_years_exist
    and_secondary_subjects_exist
    when_i_am_signed_in
    then_i_see_the_appetite_form_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_education_phase_form_page

    when_i_select_send
    and_i_click_on_continue
    then_i_see_the_key_stage_selection_form_page

    when_i_select_key_stage_2
    and_i_select_key_state_5
    and_i_click_on_continue
    then_i_see_the_note_to_providers_form_page

    when_i_enter_a_note_to_providers
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change_email_address
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

    when_i_click_on_continue
    then_i_see_the_education_phase_form_page
    and_i_see_send_selected

    when_i_click_on_continue
    then_i_see_the_key_stage_selection_form_page
    and_i_see_key_stage_2_selected
    and_i_see_key_stage_5_selected

    when_i_click_on_continue
    then_i_see_the_note_to_providers_form_page
    and_i_see_the_note_i_entered_prefilled

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change_key_stage
    then_i_see_the_key_stage_selection_form_page
    and_i_see_key_stage_2_selected
    and_i_see_key_stage_5_selected

    when_i_click_on_continue
    then_i_see_the_note_to_providers_form_page
    and_i_see_the_note_i_entered_prefilled

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change_phase
    then_i_see_the_education_phase_form_page
    and_i_see_send_selected

    when_i_click_on_continue
    then_i_see_the_key_stage_selection_form_page
    and_i_see_key_stage_2_selected
    and_i_see_key_stage_5_selected

    when_i_click_on_continue
    then_i_see_the_note_to_providers_form_page
    and_i_see_the_note_i_entered_prefilled

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_my_placement_preferences
  end

  private

  def when_i_am_signed_in
    @school = build(:school, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def given_academic_years_exist
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name
    @next_academic_year_short_name = "#{@next_academic_year.starts_on.year}/#{@next_academic_year.ends_on.strftime("%y")}"
  end

  def and_secondary_subjects_exist
    @english = create(:placement_subject, :secondary, name: "English")
    @science = create(:placement_subject, :secondary, name: "Science")
    @mathematics = create(:placement_subject, :secondary, name: "Mathematics")
  end

  def then_i_see_the_appetite_form_page
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in the #{@next_academic_year_name} academic year? - Find placement schools",
    )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in the #{@next_academic_year_name} academic year?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("Maybe", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_select_yes
    choose "Yes"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_education_phase_form_page
    expect(page).to have_title(
      "What education phase or specialism can your school offer placements in? - Find placement schools",
    )
    expect(page).to have_caption("Placement information #{@next_academic_year_short_name}")
    expect(page).to have_element(
      :legend,
      text: "What education phase or specialism can your school offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_hint("Select all that apply")
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field(
      "Special educational needs and disabilities (SEND) specific",
      type: :checkbox,
    )
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def when_i_select_send
    check "Special educational needs and disabilities (SEND) specific"
  end

  def then_i_see_the_key_stage_selection_form_page
    expect(page).to have_title(
      "Which key stages can you offer placements in a SEND setting? - Find placement schools",
    )
    expect(page).to have_caption("Placements in a SEND setting information #{@next_academic_year_short_name}")
    expect(page).to have_element(
      :legend,
      text: "Which key stages can you offer placements in a SEND setting?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Early year", type: :checkbox)
    expect(page).to have_field("Key stage 1", type: :checkbox)
    expect(page).to have_field("Key stage 2", type: :checkbox)
    expect(page).to have_field("Key stage 3", type: :checkbox)
    expect(page).to have_field("Key stage 4", type: :checkbox)
    expect(page).to have_field("Key stage 5", type: :checkbox)
    expect(page).to have_field("Mixed key stages", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def when_i_select_key_stage_2
    check "Key stage 2"
  end

  def and_i_select_key_state_5
    check "Key stage 5"
  end

  def then_i_see_the_school_contact_form_page
    expect(page).to have_title(
      "Who should providers contact? - Find placement schools",
    )
    expect(page).to have_caption("Placement contact")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_paragraph(
      "Choose the person best placed to organise placements for trainee teachers at your school",
    )
    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
  end

  def when_i_fill_in_the_school_contact_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Find placement schools",
    )
    expect(page).to have_caption("Placement information #{@next_academic_year_short_name}")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_h2("Offering placements")
    expect(page).to have_summary_list_row(
      "Can your school offer placements for trainee teachers?",
      "Yes",
    )

    expect(page).to have_h2("Education phase and specialism")
    expect(page).to have_summary_list_row("Phase", "Primary Secondary Send")

    expect(page).to have_h2("Placements in a SEND setting")
    expect(page).to have_summary_list_row("Key stage", "Key stage 2 Key stage 5")

    expect(page).to have_h2("Additional information")
    expect(page).to have_summary_list_row(
      "Message to providers",
      "We are open to hosting additional placements at the provider's request.",
    )

    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_change_email_address
    click_on "Change Email address"
  end

  def and_i_see_the_school_contact_inputs_prefilled
    expect(page).to have_field("First name", with: "Joe")
    expect(page).to have_field("Last name", with: "Bloggs")
    expect(page).to have_field("Email address", with: "joe_bloggs@example.com")
  end

  def when_i_click_on_change_key_stage
    click_on "Change Key stage"
  end

  def and_i_see_key_stage_2_selected
    expect(page).to have_checked_field("Key stage 2", type: :checkbox)
  end

  def and_i_see_key_stage_5_selected
    expect(page).to have_checked_field("Key stage 5", type: :checkbox)
  end

  def when_i_click_on_change_phase
    click_on "Change Phase"
  end

  def and_i_see_send_selected
    expect(page).to have_checked_field(
      "Special educational needs and disabilities (SEND) specific",
      type: :checkbox,
    )
  end

  def when_i_click_on_publish_placements
    click_on "Publish placement information"
  end

  def then_i_see_the_my_placement_preferences
    expect(page).to have_title(
      "What happens next? - Find placement schools",
    )
    expect(page).to have_panel(
      "Information added",
      "Providers can see that your school is offering placements for trainee teachers in the academic year #{@next_academic_year_short_name}",
    )
    expect(page).to have_h1("What happens next?")
    expect(page).to have_paragraph(
      "Providers in England can see the information you have recorded. They can email the placement contact at your school if they are interested in working together: joe_bloggs@example.com.",
    )
    expect(page).to have_paragraph(
      "You do not need to take any further action if your information is up to date.",
    )

    expect(page).to have_paragraph(
      "You can edit your schoolʼs placement information at any time.",
    )
    expect(page).to have_link(
      "edit your schoolʼs placement information",
      href: new_edit_hosting_interest_placement_preference_path(PlacementPreference.last),
    )

    expect(page).to have_h2("Placement information or your school")

    expect(page).to have_h3("Placements in a SEND setting")
    expect(page).to have_summary_list_row("Key stage", "Key stage 2 Key stage 5")

    expect(page).to have_h3("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")

    expect(page).to have_h3("Additional information")
    expect(page).to have_summary_list_row(
      "Message to providers",
      "We are open to hosting additional placements at the provider's request.",
    )
  end

  def then_i_see_the_note_to_providers_form_page
    expect(page).to have_title(
      "Is there anything about your school you would like providers to know? (optional) - Find placement schools",
    )
    expect(page).to have_caption(
      "Placement information #{@next_academic_year_short_name}",
    )
    expect(page).to have_element(
      :label,
      text: "Is there anything about your school you would like providers to know? (optional)",
    )
    expect(page).to have_hint(
      "Include any reasonable adjustments your school can offer trainee teachers with disabilities or other needs, for example wheelchair access.",
    )
    expect(page).to have_field("Is there anything about your school you would like providers to know? (optional)")
  end

  def when_i_enter_a_note_to_providers
    fill_in "Is there anything about your school you would like providers to know? (optional)", with:
      "We are open to hosting additional placements at the provider's request."
  end

  def and_i_see_the_note_i_entered_prefilled
    expect(page).to have_field(
      "Is there anything about your school you would like providers to know? (optional)",
      with: "We are open to hosting additional placements at the provider's request.",
    )
  end
end
