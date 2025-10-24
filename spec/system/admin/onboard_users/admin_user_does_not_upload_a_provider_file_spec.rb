require "rails_helper"

RSpec.describe "Admin user does not upload a provider file", type: :system do
  scenario do
    given_providers_exist
    and_i_am_signed_in
    and_i_navigate_to_onboard_users
    then_i_see_the_which_type_of_organisation_are_you_onboarding_users_for_page

    when_i_select_provider
    and_i_click_on_continue
    then_i_see_the_provider_upload_page

    when_i_click_on_upload
    then_i_see_the_errors_page
  end

  private

  def given_providers_exist
    @london_provider = create(:provider, name: "London Provider", ukprn: 111_111_11)
    @guildford_provider = create(:provider, name: "Guildford Provider", ukprn: 222_222_22)
    @york_provider = create(:provider, name: "York Provider", urn: 333_333_33)
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

  def then_i_see_the_provider_upload_page
    expect(page).to have_title("Upload users - Onboard users")
    expect(page).to have_caption("Onboard users for providers")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Error: Upload users - Onboard users - Find placement schools")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_validation_error("Select a CSV file to upload")
  end
end
