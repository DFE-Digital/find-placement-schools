require "rails_helper"

RSpec.describe "Multi provider user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_change_organisation_page

    when_i_select_order_of_the_phoenix
    then_i_see_the_find_placements_page_for_order_of_the_phoenix

    when_i_click_on_order_of_the_phoenix_organisation_link
    then_i_see_the_change_organisation_page

    when_i_select_ministry_of_magic
    then_i_see_the_find_placements_page_for_ministry_of_magic
  end

  private

  def given_i_am_signed_in
    @order_of_the_phoenix = create(:provider, name: "Order of the Phoenix")
    @ministry_of_magic = create(:provider, name: "Ministry of Magic")

    sign_in_user(organisations: [ @order_of_the_phoenix, @ministry_of_magic ])
  end

  def then_i_see_the_change_organisation_page
    expect(page).to have_title("Change organisation")
    expect(page).to have_h1("Change organisation")
    expect(page).to have_h2("Providers")
    expect(page).to have_summary_list_row("Order of the Phoenix", expected_action: "Change")
    expect(page).to have_link("Change", href: "/change_organisation/#{@order_of_the_phoenix.id}/update_organisation")
    expect(page).to have_summary_list_row("Ministry of Magic", expected_action: "Change")
    expect(page).to have_link("Change", href: "/change_organisation/#{@ministry_of_magic.id}/update_organisation")
  end

  def when_i_select_order_of_the_phoenix
    click_link "Change Order of the Phoenix"
  end

  def then_i_see_the_find_placements_page_for_order_of_the_phoenix
    expect(page).to have_title("Find placements")
    expect(page).to have_link("Order of the Phoenix (change)", href: "/change_organisation")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_success_banner("You have changed your organisation to Order of the Phoenix")
    expect(page).to have_h1("Find placements")
  end

  def when_i_click_on_order_of_the_phoenix_organisation_link
    click_link "Order of the Phoenix (change)"
  end

  def when_i_select_ministry_of_magic
    click_link "Change Ministry of Magic"
  end

  def then_i_see_the_find_placements_page_for_ministry_of_magic
    expect(page).to have_title("Find placements")
    expect(page).to have_link("Ministry of Magic (change)", href: "/change_organisation")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_success_banner("You have changed your organisation to Ministry of Magic")
    expect(page).to have_h1("Find placements")
  end
end
