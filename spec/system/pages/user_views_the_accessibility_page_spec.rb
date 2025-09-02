require "rails_helper"

RSpec.describe "User views accessibility page", type: :system do
  scenario do
    given_i_navigate_to_the_service
    and_i_click_on_accessibility
    then_i_see_the_accessibility_page
  end

  private

  def given_i_navigate_to_the_service
    visit root_path
  end

  def and_i_click_on_accessibility
    click_on "Accessibility"
  end

  def then_i_see_the_accessibility_page
    expect(page).to have_title("Accessibility statement for Find ITT placements - Find ITT placements")
    expect(page).to have_h1("Accessibility statement for Find ITT placements")
    expect(page).to have_h2("How accessible this website is")
    expect(page).to have_h2("Feedback and contact information")
  end
end
