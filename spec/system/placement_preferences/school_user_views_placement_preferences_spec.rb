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
      click_on "Placement preferences"
    end
  end

  def then_i_see_the_placement_preferences_page
    expect(page).to have_title("Placement preferences")
    expect(service_navigation).to have_current_item("Placement preferences")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement preferences")
    expect(page).to have_table_row({
      "Academic year" => AcademicYear.next.name,
      "Status" => "Placements available"
    })
  end
end
