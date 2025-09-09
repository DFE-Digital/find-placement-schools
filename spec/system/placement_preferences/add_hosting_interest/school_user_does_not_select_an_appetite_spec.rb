require "rails_helper"

RSpec.describe "School user does not select an appetite", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_academic_years_page

    when_i_select_the_next_academic_year
    and_i_click_on_continue
    then_i_see_the_appetite_form_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selection_an_appetite
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

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_a_validation_error_for_selection_an_appetite
    expect(page).to have_validation_error(
      "Please select your appetite to host ITT for the coming academic year",
    )
  end
end
