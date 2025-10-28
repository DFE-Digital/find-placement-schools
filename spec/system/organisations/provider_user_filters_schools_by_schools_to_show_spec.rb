require "rails_helper"

RSpec.describe "Provider user filters schools by schools to show", type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    then_i_see_the_find_placements_page
    and_i_see_schools_that_can_offer_placements
    and_i_see_the_schools_to_show_filter

    when_i_select_previously_hosted_from_the_schools_to_show_filer
    and_i_click_on_apply_filters
    then_i_see_only_schools_who_previously_hosted_placements
    and_i_see_previously_hosted_placements_is_now_selected
    and_i_do_not_see_any_filter_tags

    when_i_select_all_from_the_schools_to_show_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_all_schools_is_now_selected
    and_i_do_not_see_any_filter_tags

    when_i_select_not_offering_placements_from_the_schools_to_show_filter
    and_i_click_on_apply_filters
    then_i_see_only_schools_not_hosted_placements
    and_i_see_not_offering_placements_is_now_selected
    and_i_do_not_see_any_filter_tags
  end

  private

  def given_that_schools_exist
    @provider = build(:provider, name: "Ministry of Magic")

    @active_school = create(:school, :with_placement_preferences, name: "Hogwarts")
    @inactive_school = create(:school, name: "Beauxbatons")
    @previously_hosted_school = build(:school, name: "Durmstrang")
    @not_open_school = build(:school, name: "Ilvermorny")
    @previous_placement = create(
      :previous_placement,
      school: @previously_hosted_school,
      academic_year: AcademicYear.next,
    )
    @not_open_placement = create(
      :placement_preference,
      appetite: "not_open",
      organisation: @not_open_school,
      academic_year: AcademicYear.next,
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

  def and_i_see_schools_that_can_offer_placements
    expect(page).to have_h2("Hogwarts")
    expect(page).to have_h2("Durmstrang")

    expect(page).not_to have_h2("Beauxbatons")
    expect(page).not_to have_h2("Ilvermorny")
  end

  def and_i_see_the_schools_to_show_filter
    expect(page).to have_checked_field("Can offer placements", type: :radio)
    expect(page).to have_unchecked_field("Previously hosted placements", type: :radio)
    expect(page).to have_unchecked_field("Not offering placements", type: :radio)
    expect(page).to have_unchecked_field("All schools", type: :radio)
  end

  def when_i_select_all_from_the_schools_to_show_filter
    choose "All schools"
  end

  def when_i_select_not_offering_placements_from_the_schools_to_show_filter
    choose "Not offering placements"
  end

  def when_i_select_previously_hosted_from_the_schools_to_show_filer
    choose "Previously hosted placements"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_only_schools_who_previously_hosted_placements
    expect(page).to have_h2("Durmstrang")

    expect(page).not_to have_h2("Hogwarts")
    expect(page).not_to have_h2("Beauxbatons")
    expect(page).not_to have_h2("Ilvermorny")
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Hogwarts")
    expect(page).to have_h2("Beauxbatons")
    expect(page).to have_h2("Durmstrang")
    expect(page).to have_h2("Ilvermorny")
  end

  def and_i_see_previously_hosted_placements_is_now_selected
    expect(page).to have_unchecked_field("Can offer placements", type: :radio)
    expect(page).to have_checked_field("Previously hosted placements", type: :radio)
    expect(page).to have_unchecked_field("Not offering placements", type: :radio)
    expect(page).to have_unchecked_field("All schools", type: :radio)
  end

  def and_i_see_all_schools_is_now_selected
    expect(page).to have_unchecked_field("Can offer placements", type: :radio)
    expect(page).to have_unchecked_field("Previously hosted placements", type: :radio)
    expect(page).to have_unchecked_field("Not offering placements", type: :radio)
    expect(page).to have_checked_field("All schools", type: :radio)
  end

  def and_i_do_not_see_any_filter_tags
    expect(page).not_to have_css(".app-filter__tag")
  end

  def then_i_see_only_schools_not_hosted_placements
    expect(page).to have_h2("Ilvermorny")

    expect(page).not_to have_h2("Hogwarts")
    expect(page).not_to have_h2("Durmstrang")
    expect(page).not_to have_h2("Beauxbatons")
  end

  def and_i_see_not_offering_placements_is_now_selected
    expect(page).to have_unchecked_field("Can offer placements", type: :radio)
    expect(page).to have_unchecked_field("Previously hosted placements", type: :radio)
    expect(page).to have_checked_field("Not offering placements", type: :radio)
    expect(page).to have_unchecked_field("All schools", type: :radio)
  end
end
