require "rails_helper"

RSpec.describe "Single school user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_placement_preferences_form_page
    and_do_not_see_the_change_organisation_link
  end

  private

  def given_i_am_signed_in
    @current_academic_year = create(:academic_year, :current)
    @current_academic_year_name = @current_academic_year.name
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name

    @school = build(:school, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def then_i_see_the_placement_preferences_form_page
    expect(page).to have_title(
                      "For which academic year are you providing information about placements for trainee teachers? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "For which academic year are you providing information about placements for trainee teachers?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field(@current_academic_year_name, type: :radio)
    expect(page).to have_field(@next_academic_year_name, type: :radio)
  end

  def and_do_not_see_the_change_organisation_link
    expect(page).not_to have_link("Hogwarts (change)", href: "/change_organisation")
  end
end
