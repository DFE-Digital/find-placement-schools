require "rails_helper"

RSpec.describe "School user does not enter school contact details", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_appetite_form_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_entering_a_school_contact_email_address
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
  end

  def then_i_see_the_appetite_form_page
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

  def when_i_select_yes
    choose "Yes"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_school_contact_form_page
    expect(page).to have_title(
      "Who should providers contact? - Find placement schools",
    )
    expect(page).to have_caption("Placement contact")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_hint(
      "Choose the person best placed to organise placements for trainee teachers at your school",
    )
    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
  end

  def then_i_see_a_validation_error_for_entering_a_school_contact_email_address
    expect(page).to have_validation_error(
      "Enter an email address",
    )
  end
end
