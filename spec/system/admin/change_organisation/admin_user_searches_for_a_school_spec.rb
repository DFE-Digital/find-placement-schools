require "rails_helper"

RSpec.describe "Admin user searches for a school", type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_navigate_to_select_school_organisation_option
    then_i_see_the_select_a_school_to_view_page
    and_i_see_all_schools

    when_i_search_for_beauxbatons
    and_i_click_submit
    then_i_see_beauxbatons_academy_of_magic
    and_i_do_not_see_hogwarts_school_of_witchcraft_and_wizardry

    when_i_click_on_clear
    then_i_see_all_schools
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

  alias_method :then_i_see_all_schools, :and_i_see_all_schools

  def when_i_search_for_beauxbatons
    fill_in "Search for a school", with: "Beauxbatons"
  end

  def and_i_click_submit
    click_on "Submit"
  end

  def then_i_see_beauxbatons_academy_of_magic
    expect(page).to have_summary_list_row("Beauxbatons Academy of Magic", "Select")
  end

  def and_i_do_not_see_hogwarts_school_of_witchcraft_and_wizardry
    expect(page).not_to have_summary_list_row("Hogwarts School of Witchcraft and Wizardry", "Select")
  end

  def when_i_click_on_clear
    click_on "Clear"
  end
end
