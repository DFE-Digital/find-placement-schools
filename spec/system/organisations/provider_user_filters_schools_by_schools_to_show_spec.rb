require "rails_helper"

RSpec.describe "Provider user filters schools by schools to show", type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    then_i_see_the_find_placements_page
    and_i_see_all_schools
    and_i_see_the_schools_to_show_filter

    when_i_select_offering_placements_from_the_schools_to_show_filter
    and_i_click_on_apply_filters
    then_i_see_only_schools_who_are_hosting_placements
    and_i_see_offering_placements_is_now_selected
    and_i_see_the_offering_placements_filter_tag

    when_i_select_potentially_offering_placements_from_the_schools_to_show_filter
    and_i_click_on_apply_filters
    then_i_see_both_offering_and_potentially_offering_schools
    and_i_see_potentially_offering_placements_is_now_selected
    and_i_see_offering_and_potentially_offering_filter_tags

    when_i_select_previously_hosted_from_the_schools_to_show_filer
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_previously_hosted_placements_is_now_selected
    and_i_see_all_previously_selected_filter_tags
  end

  private

  def given_that_schools_exist
    @provider = build(:provider, name: "Ministry of Magic")

    @active_school = create(:school, :with_placement_preferences, name: "Hogwarts")
    @potentially_active_school = create(:school, name: "Beauxbatons")
    @previously_hosted_school = build(:school, name: "Durmstrang")
    @previous_placement = create(
      :previous_placement,
      school: @previously_hosted_school,
      academic_year: AcademicYear.previous,
    )
    @interested_placement = create(
      :placement_preference,
      appetite: "interested",
      organisation: @potentially_active_school,
      academic_year: AcademicYear.current,
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

  def and_i_see_all_schools
    expect(page).to have_h2("Hogwarts")
    expect(page).to have_h2("Durmstrang")
    expect(page).to have_h2("Beauxbatons")
  end

  def and_i_see_the_schools_to_show_filter
    expect(page).to have_unchecked_field("Offering placements", type: :checkbox)
    expect(page).to have_unchecked_field("Potentially offering placements", type: :checkbox)
    expect(page).to have_unchecked_field("Previously hosted placements", type: :checkbox)
  end

  def when_i_select_offering_placements_from_the_schools_to_show_filter
    check "Offering placements"
  end

  def then_i_see_only_schools_who_are_hosting_placements
    expect(page).to have_h2("Hogwarts")
    expect(page).not_to have_h2("Beauxbatons")
    expect(page).not_to have_h2("Durmstrang")
  end

  def and_i_see_offering_placements_is_now_selected
    expect(page).to have_checked_field("Offering placements", type: :checkbox)
  end

  def and_i_see_the_offering_placements_filter_tag
    expect(page).to have_css(".app-filter__tag", text: "Offering placements")
  end

  def when_i_select_potentially_offering_placements_from_the_schools_to_show_filter
    check "Potentially offering placements"
  end

  def then_i_see_both_offering_and_potentially_offering_schools
    expect(page).to have_h2("Hogwarts")
    expect(page).to have_h2("Beauxbatons")

    expect(page).not_to have_h2("Durmstrang")
  end

  def and_i_see_potentially_offering_placements_is_now_selected
    expect(page).to have_checked_field("Offering placements", type: :checkbox)
    expect(page).to have_checked_field("Potentially offering placements", type: :checkbox)
  end

  def and_i_see_offering_and_potentially_offering_filter_tags
    expect(page).to have_css(".app-filter__tag", text: "Offering placements")
    expect(page).to have_css(".app-filter__tag", text: "Potentially offering placements")
  end

  def when_i_select_previously_hosted_from_the_schools_to_show_filer
    check "Previously hosted placements"
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Durmstrang")
    expect(page).to have_h2("Hogwarts")
    expect(page).to have_h2("Beauxbatons")
  end

  def and_i_see_previously_hosted_placements_is_now_selected
    expect(page).to have_checked_field("Previously hosted placements", type: :checkbox)
  end

  def and_i_see_all_previously_selected_filter_tags
    expect(page).to have_css(".app-filter__tag", text: "Offering placements")
    expect(page).to have_css(".app-filter__tag", text: "Potentially offering placements")
    expect(page).to have_css(".app-filter__tag", text: "Previously hosted placements")
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end
end
