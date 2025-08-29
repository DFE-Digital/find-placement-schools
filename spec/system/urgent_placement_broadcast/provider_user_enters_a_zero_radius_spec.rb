require "rails_helper"

RSpec.describe "Provider user enters a zero radius", type: :system do
  before { Flipper.enable(:provider_help_find_placements_broadcast) }

  after { Flipper.disable(:provider_help_find_placements_broadcast) }

  scenario do
    given_schools_exist_with_placement_preferences
    when_i_am_signed_in
    then_i_see_the_find_placements_page
    and_i_see_the_help_find_placements_button

    when_i_click_on_help_find_placements
    then_i_see_the_location_search_form_page

    when_i_enter_a_location
    and_i_enter_a_zero_radius

    and_i_click_on_continue
    and_i_see_a_validation_error_for_not_entering_a_whole_number_radius
  end

  private

  def given_schools_exist_with_placement_preferences
    placement_details = {
      "appetite" => { "appetite" => "actively_looking" },
      "phase" => { "phases" => %w[primary] },
      "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
      "school_contact" => {
        "first_name" => "Joe",
        "last_name" => "Bloggs",
        "email_address" => "joe_bloggs@example.com"
      }
    }
    @schools = create_list(:school, 50)
    @schools.each do |school|
      create(
        :placement_preference,
        organisation: school,
        academic_year: AcademicYear.next,
        placement_details:,
        )
    end
    allow_any_instance_of(School).to receive(:distance_to).and_return(1.234)
    allow(SchoolsQuery).to receive(:call).and_return(
      School.where(id: @schools.pluck(:id)),
      )
  end
  def when_i_am_signed_in
    @provider = create(:provider)
    sign_in_user(organisations: [ @provider ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements - Find ITT placements")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
    expect(page).to have_h2("Filter")
  end

  def and_i_see_the_help_find_placements_button
    expect(page).to have_inset_text(
                      "If you require urgent assistance in finding a placement school to host an ITT trainee," \
                        " please click \"Help find placements\"."
                    )
    expect(page).to have_link("Help find placements", class: "govuk-button")
  end

  def when_i_click_on_help_find_placements
    click_on "Help find placements"
  end

  def then_i_see_the_location_search_form_page
    expect(page).to have_title("Location search - Help find placements - Find ITT placements")
    expect(page).to have_caption("Help find placements")
    expect(page).to have_h1("Location search")
    expect(page).to have_field("Location", type: "text")
    expect(page).to have_field("Radius", type: "number")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: organisations_path)
  end

  def when_i_enter_a_location
    fill_in "Location", with: "London"
  end

  def and_i_enter_a_zero_radius
    fill_in "Radius", with: "0"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue


  def and_i_see_a_validation_error_for_not_entering_a_whole_number_radius
    expect(page).to have_validation_error("Radius must be greater than 0")
  end
end
