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
    expect(page).to have_paragraph(
      "Use this service if you are a school or teacher training provider in England."
    )
    expect(page).to have_paragraph(
      "All schools in England should use this service."
    )

    expect(page).to have_h2("Schools")

    expect(page).to have_paragraph(
      "Use this service to record your school’s ability to offer school placements for trainee teachers."
    )
    expect(page).to have_paragraph(
      "This helps teacher training providers know whether to contact your school and helps the Department for Education (DfE) understand school capacity to support teacher training."
    )

    expect(page).to have_h2("Teacher training providers")
    expect(page).to have_paragraph(
      "Use this service to find placement schools for your trainee teachers. You can view information about the schools and find contact details to enquire about placements."
    )

    expect(page).to have_h2("Before you get started")
    expect(page).to have_paragraph(
      "To access this service, you will be asked to sign in using your DfE Sign-in account or to create one if you do not have one. DfE Sign-in is how schools and other education organisations access DfE online services."
    )
    expect(page).to have_paragraph(
      "This service is being trialled by the DfE with schools and teacher training providers in England."
    )

    expect(page).to have_link("Start now", href: "/sign-in")
  end
end
