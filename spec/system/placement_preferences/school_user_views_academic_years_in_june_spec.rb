require "rails_helper"

RSpec.describe "School user views academic years in June", type: :system do
  scenario "School user sees three academic years in June" do
    Timecop.travel(Date.parse("15 June 2025")) do
      given_academic_years_exist
      when_i_am_signed_in
      when_i_navigate_to_placement_preferences
      then_i_see_three_academic_years_displayed
    end
  end

  scenario "School user sees two academic years outside June" do
    Timecop.travel(Date.parse("15 December 2025")) do
      given_academic_years_exist
      when_i_am_signed_in
      when_i_navigate_to_placement_preferences
      then_i_see_two_academic_years_displayed
    end
  end

  private

  def given_academic_years_exist
    @current_academic_year = AcademicYear.current
    @next_academic_year = AcademicYear.next
  end

  def when_i_am_signed_in
    @school = build(:school, name: "Hogwarts")
    create(:placement_preference,
           organisation: @school,
           academic_year: @current_academic_year,
           appetite: "actively_looking")
    sign_in_user(organisations: [ @school ])
  end

  def when_i_navigate_to_placement_preferences
    within(service_navigation) do
      click_on "Placement information"
    end
  end

  def then_i_see_three_academic_years_displayed
    expect(page).to have_title("Placement information - Find placement schools")
    expect(page).to have_table_row({
      "Academic year" => @current_academic_year.name,
      "Status" => "Offering placements"
    })
    expect(page).to have_table_row({
      "Academic year" => @next_academic_year.name,
      "Status" => "No information added"
    })
    expect(page).to have_table_row({
      "Academic year" => AcademicYear.for_display.last.name,
      "Status" => "No information added"
    })
  end

  def then_i_see_two_academic_years_displayed
    expect(page).to have_title("Placement information - Find placement schools")
    expect(page).to have_table_row({
      "Academic year" => @current_academic_year.name,
      "Status" => "Offering placements"
    })
    expect(page).to have_table_row({
      "Academic year" => @next_academic_year.name,
      "Status" => "No information added"
    })
    expect(page).to have_css("tbody tr", count: 2)
  end
end
