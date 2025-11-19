require "rails_helper"

RSpec.describe "Admin user changes organisation to a provider", type: :system do
  scenario do
    given_that_providers_exist
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_navigate_to_select_provider_organisation_option
    then_i_see_the_select_a_provider_to_view_page
    and_i_see_all_providers

    when_i_select_ministry_of_magic
    then_i_see_the_find_placements_page

    when_i_click_on_return_to_dashboard
    then_i_see_the_admin_dashboard
  end

  private

  def given_that_providers_exist
    @order_of_the_phoenix = create(:provider, name: "Order of the Phoenix")
    @ministry_of_magic = create(:provider, name: "Ministry of Magic")
  end

  def and_i_am_signed_in
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard
    expect(page).to have_title("Admin dashboard - Find placement schools")
    expect(page).to have_h1("Admin dashboard")
  end

  def when_i_navigate_to_select_provider_organisation_option
    click_on "Select a provider to view"
  end

  def then_i_see_the_select_a_provider_to_view_page
    expect(page).to have_title("Select a provider to view - Find placement schools")
    expect(page).to have_h1("Select a provider to view")
  end

  def and_i_see_all_providers
    expect(page).to have_summary_list_row("Ministry of Magic", "Select")
    expect(page).to have_summary_list_row("Order of the Phoenix", "Select")
  end

  def when_i_select_ministry_of_magic
    click_on "Continue Ministry of Magic"
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_important_banner("You have changed your organisation to Ministry of Magic")
    expect(page).to have_h1("Find placements")
  end

  def when_i_click_on_return_to_dashboard
    click_on "Ministry of Magic (return to dashboard)"
  end
end
