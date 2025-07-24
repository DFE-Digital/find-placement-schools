require "rails_helper"

RSpec.describe "Single provider user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_find_placements_page
    and_do_not_see_the_change_organisation_link
  end

  private

  def given_i_am_signed_in
    @provider = create(:provider, name: "Order of the Phoenix")
    sign_in_user(organisations: [ @provider ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
  end

  def and_do_not_see_the_change_organisation_link
    expect(page).not_to have_link("Order of the Phoenix (change)", href: "/change_organisation")
  end
end
