require "rails_helper"

RSpec.describe "School user successfully adds their hosting interest", type: :system do
  scenario do
    given_academic_years_exist
    and_secondary_subjects_exist
    when_i_am_signed_in
    then_i_see_the_appetite_form_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_education_phase_form_page

    when_i_select_send
    and_i_click_on_continue
    then_i_see_the_key_stage_selection_form_page

    when_i_select_key_stage_2
    and_i_select_key_state_5
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change_email_address
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change_key_stage
    then_i_see_the_key_stage_selection_form_page
    and_i_see_key_stage_2_selected
    and_i_see_key_stage_5_selected

    when_i_click_on_continue
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

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
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

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
  end

  def and_secondary_subjects_exist
    @english = create(:placement_subject, :secondary, name: "English")
    @science = create(:placement_subject, :secondary, name: "Science")
    @mathematics = create(:placement_subject, :secondary, name: "Mathematics")
  end

  def then_i_see_the_appetite_form_page
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}? - Find placement schools",
    )
    expect(page).to have_caption("Placement preferences")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes - I can offer placements", type: :radio)
    expect(page).to have_field("Maybe - I’m not sure yet", type: :radio)
    expect(page).to have_field("No - I can’t offer placements", type: :radio)
  end

  def when_i_select_yes
    choose "Yes - I can offer placements"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_education_phase_form_page
    expect(page).to have_title(
      "What education phase can your placements be? - Find placement schools",
    )
    expect(page).to have_caption("Placement details")
    expect(page).to have_element(
      :legend,
      text: "What education phase can your placements be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_hint("Select all that apply")
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field(
      "Special educational needs and disabilities (SEND) specific",
      type: :checkbox,
    )
  end

  def when_i_select_send
    check "Special educational needs and disabilities (SEND) specific"
  end

  def then_i_see_the_key_stage_selection_form_page
     expect(page).to have_title(
      "What key stages can you offer SEND placements in? - Find placement schools",
    )
    expect(page).to have_caption("SEND placement details")
    expect(page).to have_element(
      :legend,
      text: "What key stages can you offer SEND placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Early year", type: :checkbox)
    expect(page).to have_field("Key stage 1", type: :checkbox)
    expect(page).to have_field("Key stage 2", type: :checkbox)
    expect(page).to have_field("Key stage 3", type: :checkbox)
    expect(page).to have_field("Key stage 4", type: :checkbox)
    expect(page).to have_field("Key stage 5", type: :checkbox)
    expect(page).to have_field("Mixed key stages", type: :checkbox)
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
    expect(page).to have_caption("Contact details")
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
    expect(page).to have_h1("Check your answers")

    expect(page).to have_h2("Education phase")
    expect(page).to have_summary_list_row("Phase", "Primary Secondary Send")

    expect(page).to have_h2("SEND placements")
    expect(page).to have_summary_list_row("Key stage", "Key stage 2 Key stage 5")

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
    click_on "Publish placements"
  end

  def then_i_see_the_my_placement_preferences
    expect(page).to have_title(
      "What happens next? - Find placement schools",
    )
    expect(page).to have_h1("What happens next?")
    expect(page).to have_paragraph(
      "Providers will be able to contact you on about your placement offers.",
    )
    expect(page).to have_paragraph(
      "You do not need to take any further action until providers contact you. After discussions with one or more providers, you can then decide whether to assign providers to your placements.",
    )
    expect(page).to have_paragraph(
      "Assigning a provider to a placement in this service is not a contractual agreement for a trainee to be placed in your school. An agreement must be made between you and the provider outside this service.",
    )

    expect(page).to have_h2("Manage your placements")
    expect(page).to have_link("Edit your placements", href: "")
    expect(page).to have_paragraph(
      "Edit your placements to change or remove information.",
    )

    expect(page).to have_h3("SEND placements")
    expect(page).to have_summary_list_row("Key stage", "Key stage 2 Key stage 5")

    expect(page).to have_h3("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end
end
