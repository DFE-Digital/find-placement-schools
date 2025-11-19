require "rails_helper"

RSpec.describe "Admin user invites a colleague to the service", type: :system do
  scenario do
    given_that_i_am_signed_in_as_an_admin_user
    then_i_see_the_admin_dashboard_page

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page

    when_i_click_on_add_a_user
    then_i_see_the_user_details_page

    when_i_click_on_continue
    then_i_see_form_errors

    when_i_fill_in_the_user_details_form_with_an_invalid_email
    and_i_click_on_continue
    then_i_see_invalid_admin_email_error

    when_i_fill_in_the_user_details_form_with_valid_information
    and_i_click_on_continue
    then_i_see_the_confirm_user_details_page

    when_i_click_on_confirm_and_add_user
    then_i_see_the_users_page_with_a_success_message
  end

  private

  def given_that_i_am_signed_in_as_an_admin_user
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard_page
    expect(page).to have_title("Admin dashboard - Find placement schools")
    expect(service_navigation).to have_current_item("Dashboard")
    expect(page).to have_h1("Admin dashboard")
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
    expect(page).to have_link("Back", href: "/admin/users")
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

  def when_i_fill_in_the_user_details_form_with_an_invalid_email
    fill_in "First name", with: "Hermione"
    fill_in "Last name", with: "Granger"
    fill_in "Email address", with: "hermione.granger@hogwarts.com"
  end

  def then_i_see_invalid_admin_email_error
    expect(page).to have_validation_error("Enter a Department for Education email address in the correct format, like name@education.gov.uk")
  end

  def when_i_fill_in_the_user_details_form_with_valid_information
    fill_in "First name", with: "Hermione"
    fill_in "Last name", with: "Granger"
    fill_in "Email address", with: "hermione.granger@education.gov.uk"
  end

  def then_i_see_the_confirm_user_details_page
    expect(page).to have_title("Confirm user details - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("Add user")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("First name", "Hermione", "Change")
    expect(page).to have_summary_list_row("Last name", "Granger", "Change")
    expect(page).to have_summary_list_row("Email address", "hermione.granger@education.gov.uk", "Change")
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
      "Hermione is now able to access this service"
    )
  end
end
