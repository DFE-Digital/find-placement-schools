require "rails_helper"

RSpec.describe "School user does not select an academic year", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_academic_years_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_an_academic_year
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
                      "Which academic year do you want to add placement information for? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "Which academic year do you want to add placement information for?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field(@current_academic_year_name, type: :radio)
    expect(page).to have_field(@next_academic_year_name, type: :radio)
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_a_validation_error_for_selecting_an_academic_year
    expect(page).to have_validation_error(
      "Please select an academic year",
    )
  end
end
