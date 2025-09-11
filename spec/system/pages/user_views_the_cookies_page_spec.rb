require "rails_helper"

RSpec.describe "User views cookies page", type: :system do
  scenario do
    given_i_navigate_to_the_service
    and_i_click_on_cookies
    then_i_see_the_cookies_page
  end

  private

  def given_i_navigate_to_the_service
    visit root_path
  end

  def and_i_click_on_cookies
    click_on "Cookies"
  end

  def then_i_see_the_cookies_page
    expect(page).to have_title("Cookies on Find placement schools - Find placement schools")
    expect(page).to have_h1("Cookies on Find placement schools")
    expect(page).to have_h2("Essential cookies")
  end
end
