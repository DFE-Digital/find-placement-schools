require "rails_helper"

RSpec.describe "Admin user signs in and returns to the start page", type: :system do
  scenario do
    given_i_am_signed_in_as_an_admin_user
    then_i_see_the_admin_dashboard_page

    when_i_visit_the_root_path
    then_i_see_the_start_page

    when_i_click_on_start_now
    then_i_see_the_admin_dashboard_page
  end

  private

  def given_i_am_signed_in_as_an_admin_user
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard_page
    expect(page).to have_title("Admin dashboard - Find placement schools")
    expect(page).to have_h1("Admin dashboard")
  end

  def when_i_visit_the_root_path
    visit "/"
  end

  def then_i_see_the_start_page
    expect(page).to have_title("Find placement schools")
    expect(page).to have_h1("Find placement schools")
    expect(page).to have_link("Start now", href: "/sign-in")
  end

  def when_i_click_on_start_now
    click_link "Start now"
  end
end
