require "rails_helper"

RSpec.describe "School user views placement preferences", type: :system do
  scenario do
    given_i_am_signed_in
    when_i_navigate_to_placement_preferences
    then_i_see_the_placement_preferences_page
  end

  private

  def given_i_am_signed_in
    @school = create(:school, :with_placement_preferences, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def when_i_navigate_to_placement_preferences
    within(service_navigation) do
      click_on "Placement information"
    end
  end

  def then_i_see_the_placement_preferences_page
    expect(page).to have_title("Placement information")
    expect(service_navigation).to have_current_item("Placement information")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement information")
    expect(page).to have_table_row({
      "Academic year" => AcademicYear.next.name,
      "Status" => "Placements available"
    })
    expect(page).to have_table_row({
      "Academic year" => AcademicYear.current.name,
      "Status" => "No information added",
    })
  end

  def when_i_click_on_click_here
    click_on "Click here"
  end
end
