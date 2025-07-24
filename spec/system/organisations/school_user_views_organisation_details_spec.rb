require "rails_helper"

RSpec.describe "School user views organisation details", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_placement_preferences_page

    when_i_navigate_to_organisation_details
    then_i_see_the_organisation_details_page
  end

  private

  def given_i_am_signed_in
    @school = create(
      :school,
      name: "Hogwarts",
      ukprn: "100323043",
      urn: "136534",
      telephone: "01234 567890",
      website: "http://www.hogwarts.ac.uk",
      organisation_address: build(:organisation_address, address_1: "Hogwarts School", address_2: "Hogsmeade", town: "Scotland", postcode: "AB12 3CD"),
    )
    sign_in_user(organisations: [ @school ])
  end

  def then_i_see_the_placement_preferences_page
    expect(page).to have_title("Placement preferences")
    expect(service_navigation).to have_current_item("Placement preferences")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement preferences")
  end

  def when_i_navigate_to_organisation_details
    click_on "Organisation details"
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_title("Organisation details")
    expect(service_navigation).to have_current_item("Organisation details")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Organisation details")

    expect(page).to have_summary_list_row("Organisation name", "Hogwarts")
    expect(page).to have_summary_list_row("UKPRN", "100323043")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "136534")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
    expect(page).to have_summary_list_row("Website", "http://www.hogwarts.ac.uk")
    expect(page).to have_summary_list_row("Address", "Hogwarts School, Hogsmeade, Scotland, AB12 3CD")
  end
end
