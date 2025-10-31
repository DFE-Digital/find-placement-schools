require "rails_helper"

RSpec.describe "Provider user views a school which has previously hosted placements", type: :system do
  scenario do
    give_a_school_with_previously_hosted_placements
    and_i_am_signed_in
    then_i_see_the_find_placements_page
    and_i_see_the_school_with_previously_hosted_placements
  end

  private

  def give_a_school_with_previously_hosted_placements
    @previous_academic_year = AcademicYear.for_date(Time.now - 1.year)
    @academic_year_2_years_ago = AcademicYear.for_date(Time.now - 2.years)
    @english = build(:placement_subject, name: "English", code: "A1")
    @science = build(:placement_subject, name: "Science", code: "B2")
    @school = create(
      :school,
      name: "Hogwarts",
      minimum_age: 11,
      maximum_age: 18,
      phase: "Secondary",
      group: "Local authority maintained schools",
      organisation_address: build(:organisation_address, address_1: "Hogwarts School", address_2: "Hogsmeade", town: "Scotland", postcode: "AB12 3CD"),
      previous_placements: [
        build(:previous_placement, placement_subject: @english, academic_year: @previous_academic_year),
        build(:previous_placement, placement_subject: @science, academic_year: @academic_year_2_years_ago)
      ]
    )
  end

  def and_i_am_signed_in
    @provider = build(:provider, name: "Order of the Phoenix")

    sign_in_user(organisations: [ @provider ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
  end

  def and_i_see_the_school_with_previously_hosted_placements
    expect(page).to have_h2("Hogwarts")
    expect(page).to have_tag("Previously offered placements", "turquoise")
    expect(page).to have_h3("School details")
    expect(page).to have_result_detail_row("Phase (age range)", "Secondary (11 to 18)")
    expect(page).to have_result_detail_row("Establishment group", "Local authority maintained schools")
    expect(page).to have_h3("Previously hosted placements")
    expect(page).to have_result_detail_row(@previous_academic_year.name, "English")
    expect(page).to have_result_detail_row(@academic_year_2_years_ago.name, "Science")
    expect(page).to have_h3("Getting there")
    expect(page).to have_result_detail_row("Address", "Hogwarts School, Hogsmeade, Scotland, AB12 3CD")
  end
end
