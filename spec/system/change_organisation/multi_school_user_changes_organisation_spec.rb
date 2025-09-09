require "rails_helper"

RSpec.describe "Multi school user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_change_organisation_page

    when_i_select_hogwarts
    then_i_see_the_placement_preferences_form_page_for_hogwarts_school

    when_i_click_on_hogwarts_change_organisation_link
    then_i_see_the_change_organisation_page

    when_i_select_springfield
    then_i_see_the_placement_preferences_form_page_for_springfield_school
  end

  private

  def given_i_am_signed_in
    @current_academic_year = create(:academic_year, :current)
    @current_academic_year_name = @current_academic_year.name
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name

    @hogwarts = build(:school, name: "Hogwarts")
    @springfield = build(:school, name: "Springfield")
    sign_in_user(organisations: [ @hogwarts, @springfield ])
  end

  def then_i_see_the_change_organisation_page
    expect(page).to have_title("Change organisation")
    expect(page).to have_h1("Change organisation")
    expect(page).to have_h2("Schools")
    expect(page).to have_summary_list_row("Hogwarts", expected_action: "Change")
    expect(page).to have_link("Change", href: "/change_organisation/#{@hogwarts.id}/update_organisation")
    expect(page).to have_summary_list_row("Springfield", expected_action: "Change")
    expect(page).to have_link("Change", href: "/change_organisation/#{@springfield.id}/update_organisation")
  end

  def when_i_select_hogwarts
    click_link "Change Hogwarts"
  end

  def then_i_see_the_placement_preferences_form_page_for_hogwarts_school
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

  def when_i_click_on_hogwarts_change_organisation_link
    click_link "Hogwarts (change)"
  end

  def when_i_select_springfield
    click_link "Change Springfield"
  end

  def then_i_see_the_placement_preferences_form_page_for_springfield_school
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
end
