require "rails_helper"

RSpec.describe "Admin user removes a colleague from the service", type: :system do
  scenario do
    given_that_i_am_an_admin_user_with_colleagues
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page

    when_i_click_on_harry_potter
    then_i_see_the_user_details_page

    when_i_click_on_remove_user
    then_i_see_the_remove_user_page

    when_i_click_on_remove_user
    then_i_see_the_users_page_with_a_success_message
  end

  private

  def given_that_i_am_an_admin_user_with_colleagues
    @harry = create(:user, :admin, first_name: "Harry", last_name: "Potter", email_address: "harry.potter@education.gov.uk")
  end

  def and_i_am_signed_in
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard
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

  def when_i_click_on_harry_potter
    click_on "Harry Potter"
  end

  def then_i_see_the_user_details_page
    expect(page).to have_title("Harry Potter - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("User details")
    expect(page).to have_h1("Harry Potter")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("First name", "Harry")
    expect(page).to have_summary_list_row("Last name", "Potter")
    expect(page).to have_summary_list_row("Email address", "harry.potter@education.gov.uk")
  end

  def when_i_click_on_remove_user
    click_on "Remove user"
  end

  def then_i_see_the_remove_user_page
    expect(page).to have_title("Are you sure you want to remove Harry Potter? - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_caption("Remove user")
    expect(page).to have_h1("Are you sure you want to remove Harry Potter?")
    expect(page).to have_button("Remove user")
  end

  def then_i_see_the_users_page_with_a_success_message
    expect(page).to have_title("Users - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_success_banner("User account removed")
  end
end
