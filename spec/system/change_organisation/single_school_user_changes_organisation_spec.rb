require "rails_helper"

RSpec.describe "Single school user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_placement_preferences_page
    and_do_not_see_the_change_organisation_link
  end

  private

  def given_i_am_signed_in
    @school = create(:school, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def then_i_see_the_placement_preferences_page
    expect(page).to have_title("Placement preferences")
    expect(service_navigation).to have_current_item("Placement preferences")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement preferences")
  end

  def and_do_not_see_the_change_organisation_link
    expect(page).not_to have_link("Hogwarts (change)", href: "/change_organisation")
  end
end
