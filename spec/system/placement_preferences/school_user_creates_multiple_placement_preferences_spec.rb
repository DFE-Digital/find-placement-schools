require "rails_helper"

RSpec.describe "School user creates multiple placement preferences", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_appetite_form_page_for_current_academic_year

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page

    when_i_select_no_mentors_available_due_to_capacity
    and_i_click_on_continue

    then_i_see_the_are_you_sure_page
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_continue
    then_i_see_the_confirmation_page

    when_i_click_on_placement_information
    then_i_see_the_placements_preferences_page
    and_i_see_my_placement_preference_for_current_academic_year

    when_i_click_on_add_placement_information
    then_i_see_the_appetite_form_page_for_next_academic_year

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page_for_next_academic_year

    when_i_select_no_mentors_available_due_to_capacity
    and_i_click_on_continue
    then_i_see_the_are_you_sure_page_for_next_academic_year
    and_i_see_the_reason_not_hosting_i_entered
    and_i_see_the_entered_school_contact_details

    when_i_click_on_continue
    then_i_see_the_confirmation_page

    when_i_click_on_placement_information
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
    @current_academic_year_short_name = "#{@current_academic_year.starts_on.year}/#{@current_academic_year.ends_on.strftime("%y")}"
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name
    @next_academic_year_short_name = "#{@next_academic_year.starts_on.year}/#{@next_academic_year.ends_on.strftime("%y")}"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_appetite_form_page_for_current_academic_year
    expect(page).to have_title(
                      "Can your school offer placements for trainee teachers in the #{@current_academic_year_name} academic year? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "Can your school offer placements for trainee teachers in the #{@current_academic_year_name} academic year?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("Maybe", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_select_no
    choose "No"
  end

  def then_i_see_the_reason_for_not_hosting_form_page
    expect(page).to have_title(
                      "Tell us why your school cannot offer placements for trainee teachers",
                      )
    expect(page).to have_caption("Not offering placements #{@current_academic_year_short_name}")
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

  def then_i_see_the_school_contact_form_page
    expect(page).to have_title(
                      "Who can we contact in your school? - Find placement schools",
                      )
    expect(page).to have_caption("Placement contact")
    expect(page).to have_h1("Who can we contact in your school?")
    expect(page).to have_hint(
                      "We will email to ask if your school can offer placements for trainee teachers in future academic years.",
                      )
    expect(page).to have_hint(
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
    expect(page).to have_caption("Not offering placements #{@current_academic_year_short_name}")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_paragraph(
                      "Providers in England can see that your school is unable to offer placements for trainee teachers in #{@current_academic_year_short_name}. They will not be able to see the reasons why or the placement contact.",
                      )
    expect(page).to have_summary_list_row("Academic year", @current_academic_year_name)
  end

  def and_i_see_the_reason_not_hosting_i_entered
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

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
                      "What happens next? - Find placement schools",
                      )
    expect(page).to have_h1("What happens next?")
    expect(page).to have_paragraph(
                      "We will email the placement contact to ask if your school can offer placements for trainee teachers in future academic years: joe_bloggs@example.com.",
                      )
    expect(page).to have_paragraph(
                      "If you would like to host placements this year, edit placement information for your school.",
                      )
    expect(page).to have_link("edit placement information")

    expect(page).to have_h3("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_placement_information
    click_on "Placement information"
  end

  def then_i_see_the_placements_preferences_page
    expect(page).to have_title(
                      "Placement information - Find placement schools",
                      )
    expect(page).to have_h1("Placement information")
  end

  def and_i_see_my_placement_preference_for_current_academic_year
    expect(page).to have_table_row({
                                     "Academic year" => @current_academic_year_name,
                                     "Status" => "Not offering placements"
                                   })
  end

  def when_i_click_on_add_placement_information
    click_on @next_academic_year_name
  end

  def then_i_see_the_appetite_form_page_for_next_academic_year
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

  def then_i_see_the_reason_for_not_hosting_form_page_for_next_academic_year
    expect(page).to have_title(
                      "Tell us why your school cannot offer placements for trainee teachers",
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

  def then_i_see_the_are_you_sure_page_for_next_academic_year
    expect(page).to have_title(
                      "Check your answers - Find placement schools",
                      )
    expect(page).to have_caption("Not offering placements #{@next_academic_year_short_name}")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_paragraph(
                      "Providers in England can see that your school is unable to offer placements for trainee teachers in #{@next_academic_year_short_name}. They will not be able to see the reasons why or the placement contact.",
                      )

    expect(page).to have_summary_list_row("Academic year", @next_academic_year_name)
  end

  def and_i_see_my_placement_preference_for_next_academic_year
    expect(page).to have_table_row({
                                     "Academic year" => @next_academic_year_name,
                                     "Status" => "Not offering placements"
                                   })
  end

  def then_i_see_the_placements_preferences_page_without_add_link
    expect(page).to have_title(
                      "Placement information - Find placement schools",
                      )
    expect(page).to have_h1("Placement information")
    expect(page).not_to have_link("Add placement information")
  end
end
