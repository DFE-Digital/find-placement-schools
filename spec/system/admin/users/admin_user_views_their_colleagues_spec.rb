require "rails_helper"

RSpec.describe "Admin user views their colleagues", type: :system do
  scenario do
    given_that_i_am_an_admin_user_with_colleagues
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page
    and_i_see_my_colleagues
  end

  private

  def given_that_i_am_an_admin_user_with_colleagues
    @harry = create(:user, :admin, first_name: "Harry", last_name: "Potter", email_address: "harry.potter@education.gov.uk")
    @ron = create(:user, :admin, first_name: "Ron", last_name: "Weasley", email_address: "ron.weasley@education.gov.uk")
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

  def and_i_see_my_colleagues
    expect(page).to have_table_row({
      "Full name" => "Harry Potter",
      "Email" => "harry.potter@education.gov.uk"
    })

    expect(page).to have_table_row({
      "Full name" => "Ron Weasley",
      "Email" => "ron.weasley@education.gov.uk"
    })
  end
end
