require "rails_helper"

RSpec.describe "Admin user searches for a provider", type: :system do
  scenario do
    given_that_providers_exist
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_navigate_to_select_provider_organisation_option
    then_i_see_the_select_a_provider_to_view_page
    and_i_see_all_providers

    when_i_search_for_ministry
    and_i_click_submit
    then_i_see_ministry_of_magic
    and_i_do_not_see_order_of_the_phoenix

    when_i_click_on_clear
    then_i_see_all_providers
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

  alias_method :then_i_see_all_providers, :and_i_see_all_providers

  def when_i_search_for_ministry
    fill_in "Search for a provider", with: "Ministry"
  end

  def and_i_click_submit
    click_on "Submit"
  end

  def then_i_see_ministry_of_magic
    expect(page).to have_summary_list_row("Ministry of Magic", "Select")
  end

  def and_i_do_not_see_order_of_the_phoenix
    expect(page).not_to have_summary_list_row("Order of the Phoenix", "Select")
  end

  def when_i_click_on_clear
    click_on "Clear"
  end
end
