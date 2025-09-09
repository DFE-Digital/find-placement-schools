require "rails_helper"

RSpec.describe "School user creates multiple placement preferences", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_academic_years_page

    when_i_select_the_current_academic_year
    and_i_click_on_continue
    then_i_see_the_appetite_form_page_for_current_academic_year

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page

    when_i_select_no_mentors_available_due_to_capacity
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_continue
    then_i_see_the_confirmation_page

    when_i_click_on_placement_preferences
    then_i_see_the_placements_preferences_page
    and_i_see_my_placement_preference_for_current_academic_year

    when_i_click_on_add_placement_preferences
    then_i_see_the_appetite_form_page_for_next_academic_year

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page

    when_i_select_no_mentors_available_due_to_capacity
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_continue
    then_i_see_the_confirmation_page

    when_i_click_on_placement_preferences
    then_i_see_the_placements_preferences_page_without_add_link
    and_i_see_my_placement_preference_for_current_academic_year
    and_i_see_my_placement_preference_for_next_academic_year
  end

  private

  def when_i_am_signed_in
    @school = build(:school, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def given_academic_years_exist
    @current_academic_year = create(:academic_year, :current)
    @current_academic_year_name = @current_academic_year.name
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name
  end

  def then_i_see_the_academic_years_page
    expect(page).to have_title(
                      "For which academic year are you providing information about placements for trainee teachers? - Find ITT placements",
                      )
    expect(page).to have_caption("Placement preferences")
    expect(page).to have_element(
                      :legend,
                      text: "For which academic year are you providing information about placements for trainee teachers?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field(@current_academic_year_name, type: :radio)
    expect(page).to have_field(@next_academic_year_name, type: :radio)
  end

  def when_i_select_the_current_academic_year
    choose @current_academic_year_name
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_appetite_form_page_for_current_academic_year
    expect(page).to have_title(
                      "Can your school offer placements for trainee teachers in the academic year #{@current_academic_year_name}? - Find ITT placements",
                      )
    expect(page).to have_caption("Placement preferences")
    expect(page).to have_element(
                      :legend,
                      text: "Can your school offer placements for trainee teachers in the academic year #{@current_academic_year_name}?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field("Yes - I can offer placements", type: :radio)
    expect(page).to have_field("Maybe - I’m not sure yet", type: :radio)
    expect(page).to have_field("No - I can’t offer placements", type: :radio)
  end

  def when_i_select_no
    choose "No - I can’t offer placements"
  end

  def then_i_see_the_reason_for_not_hosting_form_page
    expect(page).to have_title(
                      "Tell us why you are not able to offer placements for trainee teachers - Find ITT placements",
                      )
    expect(page).to have_caption("Not offering placements this year")
    expect(page).to have_element(
                      :legend,
                      text: "Tell us why you are not able to offer placements for trainee teachers",
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

  def then_i_see_the_school_contact_form_page
    expect(page).to have_title(
                      "Who is the preferred contact for next year? - Find ITT placements",
                      )
    expect(page).to have_caption("Not offering placements this year")
    expect(page).to have_h1("Who is the preferred contact for next year?")
    expect(page).to have_paragraph(
                      "We will ask in the next academic year whether you are able to offer placements for trainee teachers.",
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
                      "Confirm and let providers know you are not offering placements - Find ITT placements",
                      )
    expect(page).to have_caption("Not offering placements this year")
    expect(page).to have_h1(
                      "Confirm and let providers know you are not offering placements",
                      )
    expect(page).to have_paragraph(
                      "We will ask in the next academic year whether you are able to offer placements for trainee teachers.",
                      )
    expect(page).to have_paragraph("No information will be shared with providers.")
    expect(page).to have_paragraph(
                      "Your reason for not offering placements be shared with the Department for Education to help understand teacher training and recruitment.",
                      )
  end

  def and_i_see_the_reason_not_hosting_i_entered
    expect(page).to have_summary_list_row(
                      "Reason for not offering",
                      "Other - Some other reason",
                      )
  end

  def and_i_see_the_entered_school_contact_details
    expect(page).to have_h2("Contact details", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
                      "What happens next? - Find ITT placements",
                      )
    expect(page).to have_h1("What happens next?")
    expect(page).to have_paragraph(
                      "We will ask in the next academic year whether you are able to offer placements for trainee teachers.",
                      )
    expect(page).to have_paragraph(
                      "If you would like to host placements this year, update your placement preferences to let providers know you’re interested.",
                      )
    expect(page).to have_link("update your placement preferences", href: "")

    expect(page).to have_h3("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_placement_preferences
    click_on "Placement preferences"
  end

  def then_i_see_the_placements_preferences_page
    expect(page).to have_title(
                      "Placement preferences - Find ITT placements",
                      )
    expect(page).to have_h1("Placement preferences")
    expect(page).to have_link("Add placement preferences")
  end

  def and_i_see_my_placement_preference_for_current_academic_year
    expect(page).to have_table_row({
                                     "Academic year" => @current_academic_year_name,
                                     "Status" => "Not offering placements"
                                   })
  end

  def when_i_click_on_add_placement_preferences
    click_on "Add placement preferences"
  end

  def then_i_see_the_appetite_form_page_for_next_academic_year
    expect(page).to have_title(
                      "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}? - Find ITT placements",
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

  def and_i_see_my_placement_preference_for_next_academic_year
    expect(page).to have_table_row({
                                     "Academic year" => @next_academic_year_name,
                                     "Status" => "Not offering placements"
                                   })
  end

  def then_i_see_the_placements_preferences_page_without_add_link
    expect(page).to have_title(
                      "Placement preferences - Find ITT placements",
                      )
    expect(page).to have_h1("Placement preferences")
    expect(page).not_to have_link("Add placement preferences")
  end
end
