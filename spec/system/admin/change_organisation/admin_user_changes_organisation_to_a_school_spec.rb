require "rails_helper"

RSpec.describe "Admin user changes organisation to a school", type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_navigate_to_select_school_organisation_option
    then_i_see_the_select_a_school_to_view_page
    and_i_see_all_schools

    when_i_select_hogwarts
    then_i_see_the_add_placement_details_page

    when_i_click_on_return_to_dashboard
    then_i_see_the_admin_dashboard
  end

  private

  def given_that_schools_exist
    @hogwarts = create(:school, name: "Hogwarts School of Witchcraft and Wizardry")
    @beauxbatons = create(:school, name: "Beauxbatons Academy of Magic")
  end

  def and_i_am_signed_in
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard
    expect(page).to have_title("Admin dashboard - Find placement schools")
    expect(page).to have_h1("Admin dashboard")
  end

  def when_i_navigate_to_select_school_organisation_option
    click_on "Select a school to view"
  end

  def then_i_see_the_select_a_school_to_view_page
    expect(page).to have_title("Select a school to view - Find placement schools")
    expect(page).to have_h1("Select a school to view")
  end

  def and_i_see_all_schools
    expect(page).to have_summary_list_row("Beauxbatons Academy of Magic", "Select")
    expect(page).to have_summary_list_row("Hogwarts School of Witchcraft and Wizardry", "Select")
  end

  def when_i_select_hogwarts
    click_on "Continue Hogwarts School of Witchcraft and Wizardry"
  end

  def then_i_see_the_add_placement_details_page
    expect(page).to have_title("Which academic year do you want to add placement information for? - Find placement schools")
    expect(page).to have_important_banner("You have changed your organisation to Hogwarts School of Witchcraft and Wizardry")
    expect(page).to have_element(
      :legend,
      text: "Which academic year do you want to add placement information for?",
      class: "govuk-fieldset__legend",
    )
  end

  def when_i_click_on_return_to_dashboard
    click_on "Hogwarts School of Witchcraft and Wizardry (return to dashboard)"
  end
end
