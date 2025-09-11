require "rails_helper"

RSpec.describe "User views home page", type: :system do
  scenario do
    given_i_navigate_to_the_service
    then_i_see_the_home_page
  end

  private

  def given_i_navigate_to_the_service
    visit root_path
  end

  def then_i_see_the_home_page
    expect(page).to have_title("Find placement schools")
    expect(page).to have_h1("Find placement schools")
    expect(page).to have_link("Start now", href: "/sign-in")
    expect(page).to have_paragraph("We can add some content here!")
    expect(page).to have_h3("Related content")
    expect(page).to have_paragraph("Coming soon")
  end
end
