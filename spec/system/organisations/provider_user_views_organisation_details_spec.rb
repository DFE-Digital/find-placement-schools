require "rails_helper"

RSpec.describe "Provider user views organisation details", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_find_placements_page

    when_i_navigate_to_organisation_details
    then_i_see_the_organisation_details_page
  end

  private

  def given_i_am_signed_in
    @provider = create(
      :provider,
      name: "Order of the Phoenix",
      ukprn: "100323043",
      urn: "136534",
      telephone: "01234 567890",
      website: "http://www.ootp.ac.uk",
      organisation_address: build(:organisation_address, address_1: "Order of the Phoenix", address_2: "Hogsmeade", town: "Scotland", postcode: "AB12 3CD"),
    )
    sign_in_user(organisations: [ @provider ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
  end

  def when_i_navigate_to_organisation_details
    click_on "Organisation details"
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_title("Organisation details")
    expect(service_navigation).to have_current_item("Organisation details")
    expect(page).to have_caption("Order of the Phoenix")
    expect(page).to have_h1("Organisation details")

    expect(page).to have_summary_list_row("Organisation name", "Order of the Phoenix")
    expect(page).to have_summary_list_row("UKPRN", "100323043")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "136534")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
    expect(page).to have_summary_list_row("Website", "http://www.ootp.ac.uk")
    expect(page).to have_summary_list_row("Address", "Order of the Phoenix, Hogsmeade, Scotland, AB12 3CD")
  end
end
