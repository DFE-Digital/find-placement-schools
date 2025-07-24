require "rails_helper"

RSpec.describe "School user views placement preferences", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_placement_preferences_page
  end

  private

  def given_i_am_signed_in
    @school = build(:school, name: "Hogwarts")
    sign_in_user(organisations: [ @school ])
  end

  def then_i_see_the_placement_preferences_page
    expect(page).to have_title("Placement preferences")
    expect(service_navigation).to have_current_item("Placement preferences")
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement preferences")

    expect(page).to have_paragraph("Coming soon!")
  end
end
