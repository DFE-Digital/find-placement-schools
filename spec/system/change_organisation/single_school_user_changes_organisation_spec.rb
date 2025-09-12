require "rails_helper"

RSpec.describe "Single school user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_placement_preferences_form_page
    and_do_not_see_the_change_organisation_link
  end

  private

  def given_i_am_signed_in
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name

    @school = build(:school, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def then_i_see_the_placement_preferences_form_page
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

  def and_do_not_see_the_change_organisation_link
    expect(page).not_to have_link("Hogwarts (change)", href: "/change_organisation")
  end
end
