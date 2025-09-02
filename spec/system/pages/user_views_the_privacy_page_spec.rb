require "rails_helper"

RSpec.describe "User views privacy page", type: :system do
  scenario do
    given_i_navigate_to_the_service
    and_i_click_on_privacy
    then_i_see_the_privacy_page
  end

  private

  def given_i_navigate_to_the_service
    visit root_path
  end

  def and_i_click_on_privacy
    click_on "Privacy"
  end

  def then_i_see_the_privacy_page
    expect(page).to have_title("Privacy notice for Find ITT placements - Find ITT placements")
    expect(page).to have_h1("Find ITT placements privacy notice")
    expect(page).to have_paragraph("Read the Privacy information: education providers’ workforce, including teachers.")
  end
end
