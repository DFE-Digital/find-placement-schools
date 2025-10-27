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
    expect(page).to have_h2("Actions for schools")
    expect(page).to have_paragraph(
      "Use this service to register your school’s ability to offer school placements for trainee teachers."
    )
    expect(page).to have_paragraph(
      "This helps teacher training providers know whether to contact you and helps the Department for Education" \
        " understand school capacity to support teacher training."
    )

    expect(page).to have_h2("Actions for providers")
    expect(page).to have_paragraph(
      "Use this service to find placement schools for your trainee teachers."
    )

    expect(page).to have_inset_text(
      "This service is being trialled by the Department for Education with schools and teacher training providers in England."
    )

    expect(page).to have_link("Start now", href: "/sign-in")
  end
end
