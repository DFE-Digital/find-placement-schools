require "rails_helper"

RSpec.describe "User views terms_and_conditions page", type: :system do
  scenario do
    given_i_navigate_to_the_service
    and_i_click_on_terms_and_conditions
    then_i_see_the_terms_and_conditions_page
  end

  private

  def given_i_navigate_to_the_service
    visit root_path
  end

  def and_i_click_on_terms_and_conditions
    click_on "Terms and conditions"
  end

  def then_i_see_the_terms_and_conditions_page
    expect(page).to have_title("Terms and conditions for Find ITT placements - Find ITT placements")
    expect(page).to have_h2("Using our website")
    expect(page).to have_h2("Information about us")
    expect(page).to have_h2("Access to the Service")
    expect(page).to have_h2("Hyperlinking to the Find ITT placements website")
  end
end
