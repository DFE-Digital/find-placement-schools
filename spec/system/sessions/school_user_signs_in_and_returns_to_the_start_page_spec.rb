require "rails_helper"

RSpec.describe "School user signs in and returns to the start page", type: :system do
  scenario do
    given_i_am_signed_in_as_a_school_user
    then_i_see_the_placement_information_page

    when_i_visit_the_root_path
    then_i_see_the_start_page

    when_i_click_on_start_now
    then_i_see_the_placement_information_page
  end

  private

  def given_i_am_signed_in_as_a_school_user
    @placement_preference = create(:placement_preference)
    @school = create(:school, placement_preferences: [ @placement_preference ])
    sign_in_user(organisations: [ @school ])
  end

  def then_i_see_the_placement_information_page
    expect(page).to have_title("Placement information - Find placement schools")
    expect(service_navigation).to have_current_item("Placement information")
    expect(page).to have_h1("Placement information")
  end

  def when_i_visit_the_root_path
    visit "/"
  end

  def then_i_see_the_start_page
    expect(page).to have_title("Find placement schools")
    expect(page).to have_h1("Find placement schools")
    expect(page).to have_link("Start now", href: "/sign-in")
  end

  def when_i_click_on_start_now
    click_link "Start now"
  end
end
