require "rails_helper"

RSpec.describe "School user views organisation details", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_placement_preferences_form_page

    when_i_navigate_to_organisation_details
    then_i_see_the_organisation_details_page
    and_i_see_the_organisation_location_details
  end

  private

  def given_i_am_signed_in
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name

    @school = build(
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

  def then_i_see_the_placement_preferences_form_page
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in the #{@next_academic_year_name} academic year? - Find placement schools",
    )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in the #{@next_academic_year_name} academic year?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("Maybe", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_navigate_to_organisation_details
    click_on "Organisation details"
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_title("Organisation details")
    expect(service_navigation).to have_current_item("Organisation details")

    within("#organisation-details") do
      expect(page).to have_caption("Hogwarts")
      expect(page).to have_h1("Organisation details")

      expect(page).to have_summary_list_row("Organisation name", "Hogwarts")
      expect(page).to have_summary_list_row("UKPRN", "100323043")
      expect(page).to have_summary_list_row("Unique reference number (URN)", "136534")
      expect(page).to have_summary_list_row("Telephone number", "01234 567890")
      expect(page).to have_summary_list_row("Website", "http://www.hogwarts.ac.uk")
    end
  end

  def and_i_see_the_organisation_location_details
    within("#location") do
      expect(page).to have_caption("Hogwarts")
      expect(page).to have_h1("Location")
      expect(page).to have_summary_list_row(
                        "Address", "Hogwarts School, Hogsmeade, Scotland, AB12 3CD",
                        )
    end
  end
end
