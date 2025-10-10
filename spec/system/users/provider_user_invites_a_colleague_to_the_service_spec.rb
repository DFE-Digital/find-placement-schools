require "rails_helper"

RSpec.describe "Provider user invites a colleague to the service", type: :system do
  scenario do
    given_that_providers_exist
    and_i_am_signed_in
    then_i_see_the_find_placements_page

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page

    when_i_click_on_add_a_user
    then_i_see_the_user_details_page

    when_i_click_on_continue
    then_i_see_form_errors

    when_i_fill_in_the_user_details_form
    and_i_click_on_continue
    then_i_see_the_confirm_user_details_page

    when_i_click_on_confirm_and_add_user
    then_i_see_the_users_page_with_a_success_message
  end

  private

  def given_that_providers_exist
    @order_of_the_phoenix = create(:provider, name: "Order of the Phoenix")
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

  def when_i_click_on_add_a_user
    click_on "Add a user"
  end

  def then_i_see_the_user_details_page
    expect(page).to have_title("User details - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("Add user")
    expect(page).to have_h1("User details")
    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Back", href: users_path)
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_form_errors
    expect(page).to have_validation_error("Enter a first name")
    expect(page).to have_validation_error("Enter a last name")
    expect(page).to have_validation_error("Enter an email address")
  end

  def when_i_fill_in_the_user_details_form
    fill_in "First name", with: "Albus"
    fill_in "Last name", with: "Dumbledore"
    fill_in "Email address", with: "albus.dumbledore@ootp.com"
  end

  def then_i_see_the_confirm_user_details_page
    expect(page).to have_title("Confirm user details - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("Add user")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("First name", "Albus", "Change")
    expect(page).to have_summary_list_row("Last name", "Dumbledore", "Change")
    expect(page).to have_summary_list_row("Email address", "albus.dumbledore@ootp.com", "Change")
    expect(page).to have_warning_text("Albus Dumbledore will be sent an email to tell them you’ve added them to Order of the Phoenix.")
    expect(page).to have_button("Confirm and add user")
  end

  def when_i_click_on_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def then_i_see_the_users_page_with_a_success_message
    expect(page).to have_title("Users - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_success_banner(
      "User added",
      "Albus is now able to use this service on behalf of Order of the Phoenix"
    )
  end
end
