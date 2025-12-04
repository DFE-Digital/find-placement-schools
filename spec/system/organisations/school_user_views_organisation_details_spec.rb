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
    @current_academic_year = create(:academic_year, :current)
    @current_academic_year_name = @current_academic_year.name
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
                      "Which academic year do you want to add placement information for? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "Which academic year do you want to add placement information for?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field(@current_academic_year_name, type: :radio)
    expect(page).to have_field(@next_academic_year_name, type: :radio)
  end

  def when_i_navigate_to_organisation_details
    click_on "School details"
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_title("School details")
    expect(service_navigation).to have_current_item("School details")

    expect(page).to have_inset_text(
      "These details will be displayed to teacher training providers." \
        " If any details are incorrect, go to the Get Information about Schools" \
        " (GIAS) (opens in new tab) service to update them."
    )
    expect(page).to have_link(
      "Get Information about Schools (GIAS) (opens in new tab)",
      href: "https://www.get-information-schools.service.gov.uk/Guidance/Governance",
    )

    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("School details")

    expect(page).to have_summary_list_row("Organisation name", "Hogwarts")
    expect(page).to have_summary_list_row("UKPRN", "100323043")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "136534")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
    expect(page).to have_summary_list_row("Website", "http://www.hogwarts.ac.uk")
  end

  def and_i_see_the_organisation_location_details
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h2("Location")
    expect(page).to have_summary_list_row(
    "Address", "Hogwarts School, Hogsmeade, Scotland, AB12 3CD",
    )
  end
end
