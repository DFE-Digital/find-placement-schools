require "rails_helper"

RSpec.describe "Multi school user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_change_organisation_page

    when_i_select_hogwarts
    then_i_see_the_placement_preferences_page_for_hogwarts

    when_i_click_on_hogwarts_change_organisation_link
    then_i_see_the_change_organisation_page

    when_i_select_springfield
    then_i_see_the_placement_preferences_page_for_springfield
  end

  private

  def given_i_am_signed_in
    @hogwarts = create(:school, name: "Hogwarts")
    @springfield = create(:school, name: "Springfield")
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

  def then_i_see_the_placement_preferences_page_for_hogwarts
    expect(page).to have_title("Placement preferences")
    expect(page).to have_link("Hogwarts (change)", href: "/change_organisation")
    expect(service_navigation).to have_current_item("Placement preferences")
    expect(page).to have_success_banner("You have changed your organisation to Hogwarts")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement preferences")
  end

  def when_i_click_on_hogwarts_change_organisation_link
    click_link "Hogwarts (change)"
  end

  def when_i_select_springfield
    click_link "Change Springfield"
  end

  def then_i_see_the_placement_preferences_page_for_springfield
    expect(page).to have_title("Placement preferences")
    expect(page).to have_link("Springfield (change)", href: "/change_organisation")
    expect(service_navigation).to have_current_item("Placement preferences")
    expect(page).to have_success_banner("You have changed your organisation to Springfield")
    expect(page).to have_caption("Springfield")
    expect(page).to have_h1("Placement preferences")
  end
end
