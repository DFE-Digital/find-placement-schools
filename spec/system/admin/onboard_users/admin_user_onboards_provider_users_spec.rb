require "rails_helper"

RSpec.describe "Admin user onboards provider users", type: :system do
  scenario do
    given_providers_exist
    and_i_am_signed_in
    and_i_navigate_to_onboard_users
    then_i_see_the_which_type_of_organisation_are_you_onboarding_users_for_page

    when_i_select_provider
    and_i_click_on_continue
    then_i_see_the_upload_page

    when_i_upload_a_valid_file
    when_i_click_on_upload
    then_i_see_the_confirm_users_you_want_to_upload_page

    when_i_click_on_confirm_upload
    then_i_see_a_success_message
  end

  private

  def given_providers_exist
    @london_provider = create(:provider, name: "London Provider", code: "1AB")
    @guildford_provider = create(:provider, name: "Guildford Provider", code: "2CD")
    @york_provider = create(:provider, name: "York Provider", code: "3EF")
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

  def when_i_select_provider
    choose "Provider"
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

  def when_i_upload_a_valid_file
    attach_file "Upload CSV file", "spec/fixtures/users/provider_users.csv"
  end

  def when_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_confirm_users_you_want_to_upload_page
    expect(page).to have_title("Are you sure you want to upload the users? - Onboard users")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Confirm you want to upload users", class: "govuk-heading-l")
    expect(page).to have_h2("Preview of provider_users.csv", class: "govuk-heading-m")
    expect(page).to have_table_row(
      "1" => "2",
      "code" => "1AB",
      "first_name" => "Jeff",
      "last_name" => "Barnes",
      "email_address" => "j.barnes@example.com",
    )
    expect(page).to have_table_row(
      "1" => "3",
      "code" => "2CD",
      "first_name" => "Jeff",
      "last_name" => "Barnes",
      "email_address" => "j.barnes@example.com",
    )
    expect(page).to have_table_row(
      "1" => "4",
      "code" => "3EF",
      "first_name" => "James",
      "last_name" => "Hill",
      "email_address" => "j.hill@example.com",
    )
    expect(page).to have_button("Confirm upload")
  end

  def when_i_click_on_confirm_upload
    click_on "Confirm upload"
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner(
      "Users have been onboarded successfully",
      "It may take a moment for the users to appear in the service.",
    )
  end
end
