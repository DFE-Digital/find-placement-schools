require "rails_helper"

RSpec.describe "Provider user removes a colleague from the service", type: :system do
  scenario do
    given_that_providers_with_users_exist
    and_i_am_signed_in
    then_i_see_the_find_placements_page

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page

    when_i_click_on_sirius_black
    then_i_see_the_user_details_page

    when_i_click_on_remove_user
    then_i_see_the_remove_user_page

    when_i_click_on_remove_user
    then_i_see_the_users_page_with_a_success_message
  end

  private

  def given_that_providers_with_users_exist
    @order_of_the_phoenix = create(:provider, name: "Order of the Phoenix")
    @sirius = create(:user, first_name: "Sirius", last_name: "Black", email_address: "sirius.black@ootp.com", organisations: [ @order_of_the_phoenix ])
  end

  def and_i_am_signed_in
    sign_in_user(organisations: [ @order_of_the_phoenix ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements - Find placement schools")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
  end

  def when_i_navigate_to_the_users_tab
    within service_navigation do
      click_on "Users"
    end
  end

  def then_i_see_the_users_page
    expect(page).to have_title("Users - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
  end

  def when_i_click_on_sirius_black
    click_on "Sirius Black"
  end

  def then_i_see_the_user_details_page
    expect(page).to have_title("Sirius Black - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("User details")
    expect(page).to have_h1("Sirius Black")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("First name", "Sirius")
    expect(page).to have_summary_list_row("Last name", "Black")
    expect(page).to have_summary_list_row("Email address", "sirius.black@ootp.com")
  end

  def when_i_click_on_remove_user
    click_on "Remove user"
  end

  def then_i_see_the_remove_user_page
    expect(page).to have_title("Are you sure you want to remove Sirius Black? - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("Remove user")
    expect(page).to have_h1("Are you sure you want to remove Sirius Black?")
    expect(page).to have_warning_text("Sirius Black will be sent an email to tell them you removed them from Order of the Phoenix.")
    expect(page).to have_button("Remove user")
  end

  def then_i_see_the_users_page_with_a_success_message
    expect(page).to have_title("Users - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_success_banner("User account removed")
  end
end
