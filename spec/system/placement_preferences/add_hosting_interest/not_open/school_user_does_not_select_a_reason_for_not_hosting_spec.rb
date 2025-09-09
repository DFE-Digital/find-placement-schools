require "rails_helper"

RSpec.describe "School user does not select a reason for not hosting", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_academic_years_page

    when_i_select_the_next_academic_year
    and_i_click_on_continue
    then_i_see_the_appetite_form_page

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_reason_for_not_hosting_form_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selection_a_reason_not_to_host
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
    @next_academic_year_short_name = "#{@next_academic_year.starts_on.year}/#{@next_academic_year.ends_on.strftime("%y")}"
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

  def when_i_select_the_next_academic_year
    choose @next_academic_year_name
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

  def then_i_see_a_validation_error_for_selection_a_reason_not_to_host
    expect(page).to have_validation_error(
      "Please select a reason for not taking part in ITT",
    )
  end
end
