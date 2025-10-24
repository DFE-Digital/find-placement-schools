require "rails_helper"

RSpec.describe "Admin user uploads a school file with invalid inputs", type: :system do
  scenario do
    given_schools_exist
    and_i_am_signed_in
    and_i_navigate_to_onboard_users
    then_i_see_the_which_type_of_organisation_are_you_onboarding_users_for_page

    when_i_select_school
    and_i_click_on_continue
    then_i_see_the_upload_page

    when_i_upload_a_file_containing_containing_invalid_inputs
    and_i_click_on_upload
    then_i_see_the_errors_page
  end

  private

  def given_schools_exist
    @london_school = create(:school, name: "London School", urn: 111111)
    @guildford_school = create(:school, name: "Guildford School", urn: 222222)
    @york_school = create(:school, name: "York School", urn: 333333)
  end

  def and_i_am_signed_in
    sign_in_admin_user
  end

  def and_i_navigate_to_onboard_users
    click_on "Onboard users"
  end

  def then_i_see_the_which_type_of_organisation_are_you_onboarding_users_for_page
    expect(page).to have_title("Which type of organisation are you onboarding users for? - Onboard users")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Which type of organisation are you onboarding users for?")
    expect(page).to have_field("School", type: :radio)
    expect(page).to have_field("Provider", type: :radio)
    expect(page).to have_button("Continue")
  end

  def when_i_select_school
    choose "School"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_upload_page
    expect(page).to have_title("Upload users - Onboard users")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_upload_a_file_containing_containing_invalid_inputs
    attach_file "Upload CSV file",
                "spec/fixtures/users/invalid_data_school_users.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Error: Upload users - Onboard users - Find placement schools")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_element(:h2, text: "There is a problem")
    expect(page).to have_element(:div, text: "You need to fix 1 error related to a specific row", class: "govuk-error-summary")
    expect(page).to have_element(:td, text: "Invalid Email", class: "govuk-table__cell", count: 1)
    expect(page).to have_element(:p, text: "Only showing rows with errors", class: "govuk-!-text-align-centre")
  end

  def and_click_on_continue
    click_on "Continue"
  end
end
