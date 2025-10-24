require "rails_helper"

RSpec.describe "School user successfully adds their hosting interest", type: :system do
  scenario do
    given_academic_years_exist
    and_secondary_subjects_exist
    and_a_placement_preference_exists
    when_i_am_signed_in
    then_i_see_the_placement_information_page

    when_i_click_on_the_next_academic_year
    then_i_see_the_school_is_offering_placements

    when_i_click_on_edit_placement_information
    then_i_see_the_appetite_form_page

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page

    when_i_select_no_mentors_available_due_to_capacity
    and_i_select_other
    and_i_enter_another_reason
    and_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_back
    then_i_see_the_reason_for_not_hosting_form_page
    and_i_see_no_mentors_available_due_to_capacity_selected
    and_i_see_other_selected

    when_i_click_on_back
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

    when_i_click_on_back
    then_i_see_the_appetite_form_page
    and_i_see_no_selected

    when_i_click_on_continue
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

    when_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page
    and_i_see_no_mentors_available_due_to_capacity_selected
    and_i_see_other_selected

    when_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_change_email_address
    then_i_see_the_school_contact_form_page
    and_i_see_the_school_contact_inputs_prefilled

    when_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page
    and_i_see_no_mentors_available_due_to_capacity_selected
    and_i_see_other_selected

    when_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_entered_school_contact_details

    when_i_click_on_change_reason_for_not_offering
    then_i_see_the_reason_for_not_hosting_form_page
    and_i_see_no_mentors_available_due_to_capacity_selected
    and_i_see_other_selected

    when_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_continue
    then_i_see_the_my_placement_preferences
  end

  private

  def when_i_am_signed_in
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

  def and_a_placement_preference_exists
    placement_details = {
      "phase" => { "phases" => %w[primary secondary send] },
      "appetite" => { "appetite" => "actively_looking" },
      "school_contact" => { "first_name" => "Joe", "last_name" => "Bloggs", "email_address" => "joe_bloggs@example.com" },
      "note_to_providers" => { "note" => "Note to providers" },
      "check_your_answers" => nil,
      "key_stage_selection" => { "key_stages" => %w[key_stage_3, key_stage_4] },
      "year_group_selection" => { "year_groups" => %w[reception year_1] },
      "secondary_subject_selection" => { "subject_ids" => [ @english.id, @science.id ] }
    }
    @school = build(:school, name: "Hogwarts")
    @placement_preference = create(
      :placement_preference,
      appetite: :actively_looking,
      organisation: @school,
      academic_year: @next_academic_year,
      placement_details:,
      )
  end

  def then_i_see_the_placement_information_page
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement information")

    expect(page).to have_element(:caption, text: "Placement information")
    expect(page).to have_table_row({
      "Academic year" => @next_academic_year_name,
      "Status" => "Placements available"
    })
  end

  def when_i_click_on_the_next_academic_year
    click_on @next_academic_year_name
  end

  def then_i_see_the_school_is_offering_placements
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
    expect(page).to have_h3("Primary placements")
    expect(page).to have_summary_list_row("Year group", "Year 1")

    expect(page).to have_h3("Secondary placements")
    expect(page).to have_summary_list_row("Subject", "English")

    expect(page).to have_h3("SEND placements")
    expect(page).to have_summary_list_row("Key stage", "Key stage 2")

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

  def when_i_click_on_edit_placement_information
    click_on "edit your schoolʼs placement information"
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

  def when_i_select_no
    choose "No"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_reason_for_not_hosting_form_page
    expect(page).to have_title(
                      "Tell us why your school cannot offer placements for trainee teachers - Find placement schools",
                      )
    expect(page).to have_caption("Not offering placements #{@next_academic_year_short_name}")
    expect(page).to have_element(
                      :legend,
                      text: "Tell us why your school cannot offer placements for trainee teachers",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field("Trainees we were offered did not meet our expectations", type: :checkbox)
    expect(page).to have_field("High number of pupils with SEND needs", type: :checkbox)
    expect(page).to have_field("Low capacity to support trainees due to staff changes", type: :checkbox)
    expect(page).to have_field("No mentors available due to capacity", type: :checkbox)
    expect(page).to have_field("Unsure how to get involved", type: :checkbox)
    expect(page).to have_field("Working to improve our OFSTED rating", type: :checkbox)
    expect(page).to have_field("Other", type: :checkbox)
  end

  def when_i_select_no_mentors_available_due_to_capacity
    check "No mentors available due to capacity"
  end

  def and_i_select_other
    check "Other"
  end

  def and_i_enter_another_reason
    fill_in "Tell us your reason", with: "Some other reason"
  end

  def then_i_see_the_school_contact_form_page
    expect(page).to have_title(
                      "Who can we contact in your school? - Find placement schools",
                      )
    expect(page).to have_caption("Placement contact")
    expect(page).to have_h1("Who can we contact in your school?")
    expect(page).to have_paragraph(
                      "We will email to ask if your school can offer placements for trainee teachers in future academic years.",
                      )
    expect(page).to have_paragraph(
                      "Choose the person best placed to organise placements for trainee teachers at your school.",
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

  def then_i_see_the_are_you_sure_page
    expect(page).to have_title(
                      "Check your answers - Find placement schools",
                      )
    expect(page).to have_caption("Not offering placements #{@next_academic_year_short_name}")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_paragraph(
                      "Providers in England can see that your school is unable to offer placements for trainee teachers in #{@next_academic_year_short_name}. They will not be able to see the reasons why or the placement contact.",
                      )
    expect(page).to have_paragraph("No information will be shared with providers.")
    expect(page).to have_paragraph(
                      "Your reason for not offering placements will be shared with the Department for Education to help understand teacher training and recruitment.",
                      )
  end

  def and_i_see_the_reason_not_hosting_i_entered
    expect(page).to have_summary_list_row(
                      "Can your school offer placements for trainee teachers?",
                      "No",
                      )
    expect(page).to have_summary_list_row(
                      "Reason for not offering",
                      "Other - Some other reason",
                      )
  end

  def and_i_see_the_entered_school_contact_details
    expect(page).to have_h2("Placement contact", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def and_i_see_the_school_contact_inputs_prefilled
    expect(page).to have_field("First name", with: "Joe")
    expect(page).to have_field("Last name", with: "Bloggs")
    expect(page).to have_field("Email address", with: "joe_bloggs@example.com")
  end

  def and_i_see_no_mentors_available_due_to_capacity_selected
    expect(page).to have_checked_field("No mentors available due to capacity", type: :checkbox)
  end

  def and_i_see_other_selected
    expect(page).to have_checked_field("Other", type: :checkbox)
  end

  def and_i_see_no_selected
    expect(page).to have_checked_field("No", type: :radio)
  end

  def when_i_click_on_change_email_address
    click_on "Change Email address"
  end

  def when_i_click_on_change_reason_for_not_offering
    click_on "Change Reason for not offering"
  end

  def then_i_see_the_my_placement_preferences
    expect(page).to have_title(
                      "What happens next? - Find placement schools",
                      )
    expect(page).to have_panel(
                      "Information added",
                      "Providers can see that your school is not offering placements for trainee teachers in the academic year #{@next_academic_year_short_name}",
                      )
    expect(page).to have_h1("What happens next?")
    expect(page).to have_paragraph(
                      "We will email the placement contact to ask if your school can offer placements for trainee teachers in future academic years: joe_bloggs@example.com",
                      )
    expect(page).to have_paragraph(
                      "If you would like to host placements this year, edit placement information for your school.",
                      )
    expect(page).to have_link(
                      "edit placement information",
                      href: new_edit_hosting_interest_placement_preference_path(PlacementPreference.last),
                      )

    expect(page).to have_h3("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end
end
