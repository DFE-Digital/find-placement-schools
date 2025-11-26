require "rails_helper"

RSpec.describe "Provider user filters schools by ITT status", type: :system do
  scenario do
    given_that_a_school_exist
    and_i_am_signed_in
    then_i_see_the_find_placements_page

    when_i_click_on_hogwarts
    then_i_see_the_organisation_details_for_hogwarts
    and_i_see_the_location_details_for_hogwarts
    and_i_see_the_placement_preference_details_for_hogwarts
  end

  private

  def given_that_a_school_exist
    @english = create(:placement_subject, name: "English")
    @mathematics = create(:placement_subject, name: "Mathematics")
    @science = create(:placement_subject, name: "Science")

    @provider = build(:provider, name: "Ministry of Magic")

    @school = build(
      :school,
      phase: "All-through",
      name: "Hogwarts",
      ukprn: "100323043",
      urn: "136534",
      telephone: "01234 567890",
      website: "http://www.hogwarts.ac.uk",
      latitude: 55.62395529715774,
      longitude: -1.753536675526344,
      organisation_address: build(
        :organisation_address,
        address_1: "Hogwarts School",
        address_2: "Hogsmeade",
        town: "Scotland",
        postcode: "AB12 3CD",
      ),
      admissions_policy: "Not applicable",
      district_admin_code: "HW123456789",
      district_admin_name: "Hogsmeade",
      gender: "Mixed",
      group: "Local authority maintained schools",
      local_authority_code: "123",
      local_authority_name: "Alnwick",
      maximum_age: 18,
      minimum_age: 11,
      percentage_free_school_meals: 90,
      religious_character: "Does not apply",
      school_capacity: 446,
      send_provision: "Resourced provision",
      special_classes: "Has Special Classes",
      total_boys: 152,
      total_girls: 140,
      total_pupils: 292,
      type_of_establishment: "Community school",
      urban_or_rural: "Urban: Further from a major town or city",
      )

    @placement_preference = create(
      :placement_preference,
      organisation: @school,
      academic_year: AcademicYear.next,
      placement_details: {
        "phase" => {
          "phases" => %w[primary secondary send]
        },
        "appetite" => {
          "appetite" => "actively_looking"
        },
        "school_contact" => {
          "first_name" => "John", "last_name" => "Smith",  "email_address" => "john_smith@example.com"
        },
        "key_stage_selection" => {
          "key_stages" => %w[key_stage_2 key_stage_5]
        },
        "year_group_selection" => {
          "year_groups" => %w[reception year_2]
        },
        "secondary_subject_selection" => {
          "subject_ids" => [ @english.id, @mathematics.id, @science.id ]
        }
      },
    )
  end

  def and_i_am_signed_in
    sign_in_user(organisations: [ @provider ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements - Find placement schools")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
    expect(page).to have_h2("Filter")
  end

  def when_i_click_on_hogwarts
    click_on "Hogwarts"
  end

  def then_i_see_the_organisation_details_for_hogwarts
    expect(page).to have_title("Organisation details - Hogwarts")
    expect(service_navigation).to have_current_item("Find placements")

    within("#organisation-details") do
      expect(page).to have_caption("Hogwarts")
      expect(page).to have_h1("Organisation details")

      expect(page).not_to have_inset_text(
        "These details will be displayed to teacher training providers." \
          " If any details are incorrect, go to the Get Information about Schools" \
          " (GIAS) (opens in new tab) service to update them."
      )
      expect(page).not_to have_link(
        "Get Information about Schools (GIAS) (opens in new tab)",
        href: "https://www.get-information-schools.service.gov.uk/Guidance/Governance",
      )

      expect(page).to have_summary_list_row("Organisation name", "Hogwarts")
      expect(page).to have_summary_list_row("UKPRN", "100323043")
      expect(page).to have_summary_list_row("Unique reference number (URN)", "136534")
      expect(page).to have_summary_list_row("Telephone number", "01234 567890")
      expect(page).to have_summary_list_row("Website", "http://www.hogwarts.ac.uk")

      expect(page).to have_h2("Additional details")
      expect(page).to have_summary_list_row("District administrative name", "Hogsmeade")
      expect(page).to have_summary_list_row("District administrative code", "HW123456789HW123456789")
      expect(page).to have_summary_list_row("Establishment group", "Local authority maintained schools")
      expect(page).to have_summary_list_row("Local authority name", "Alnwick")
      expect(page).to have_summary_list_row("Local authority code", "123")
      expect(page).to have_summary_list_row("Phase of education", "All-through")
      expect(page).to have_summary_list_row("Gender", "Mixed")
      expect(page).to have_summary_list_row("Age range", "11 to 18")
      expect(page).to have_summary_list_row("Religious character", "Does not apply")
      expect(page).to have_summary_list_row("Admissions policy", "Not applicable")
      expect(page).to have_summary_list_row("Urban or rural", "Urban: Further from a major town or city")
      expect(page).to have_summary_list_row("School capacity", "446")
      expect(page).to have_summary_list_row("Number of pupils", "292")
      expect(page).to have_summary_list_row("Number of boys", "152")
      expect(page).to have_summary_list_row("Number of girls", "140")
      expect(page).to have_summary_list_row("Percentage free school meals", "90%")

      expect(page).to have_h2("Special educational needs and disabilities (SEND)")
      expect(page).to have_summary_list_row("Special classes", "Has Special Classes")
      expect(page).to have_summary_list_row("SEND provision", "Resourced provision")

      expect(page).to have_h2("Ofsted")
      expect(page).to have_summary_list_row("Rating", "Unknown")
      expect(page).to have_summary_list_row("Last inspection date", "Unknown")
    end

    def and_i_see_the_location_details_for_hogwarts
      within("#location") do
        expect(page).to have_caption("Hogwarts")
        expect(page).to have_h1("Location")
        page.find("#map-component")
        expect(page).to have_summary_list_row(
          "Address", "Hogwarts School, Hogsmeade, Scotland, AB12 3CD",
        )
      end
    end

    def and_i_see_the_placement_preference_details_for_hogwarts
      within("#placement-information") do
        expect(page).to have_caption("Hogwarts")
        expect(page).to have_h1("Placement information")

        expect(page).to have_paragraph("Placement information is indicative. It does not reflect how many placements a school can offer.")

        expect(page).to have_h2("Primary placements")
        expect(page).to have_summary_list_row("Year group", "Reception Year 2")

        expect(page).to have_h2("Secondary placements")
        expect(page).to have_summary_list_row("Subject", "English Mathematics Science")

        expect(page).to have_h2("SEND placements")
        expect(page).to have_summary_list_row("Key stage", "Key Stage 2 Key Stage 5")

        expect(page).to have_h2("Placement contact")
        expect(page).to have_summary_list_row("First name", "John")
        expect(page).to have_summary_list_row("Last name", "Smith")
        expect(page).to have_summary_list_row("Email address", "john_smith@example.com")
      end
    end
  end
end
