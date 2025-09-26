require "rails_helper"

RSpec.describe "Admin user imports previous placement register data", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_click_on_import_register_itt_placement_data
    then_i_see_the_csv_upload_page

    when_i_upload_a_csv_containing_valid_register_data
    and_i_click_on_upload
    then_i_see_the_upload_errors_page
  end

  private
  def given_i_am_signed_in
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard
    expect(page).to have_title("Admin dashboard")
    expect(page).to have_h1("Admin dashboard")

    expect(page).to have_link("Mission control job dashboard", href: "/jobs")
    expect(page).to have_link("Import Register ITT Placement Data", href: "/admin/previous_placements/new")
  end

  def when_i_click_on_import_register_itt_placement_data
    click_on "Import Register ITT Placement Data"
  end

  def then_i_see_the_csv_upload_page
    expect(page).to have_title("Upload file - Import Register ITT Placement Data - Find placement schools")
    expect(page).to have_caption("Import Register ITT Placement Data")
    expect(page).to have_h1("Upload file")
    expect(page).to have_field("Upload CSV file", type: :file)
    expect(page).to have_button("Upload")
    expect(page).to have_link("Cancel", href: "/admin_dashboard")
  end

  def when_i_upload_a_csv_containing_valid_register_data
    attach_file "Upload CSV file", "spec/fixtures/register_trainee_teachers/import.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_upload_errors_page
    expect(page).to have_title("Upload file - Import Register ITT Placement Data - Find placement schools")
    expect(page).to have_caption("Import Register ITT Placement Data")
    expect(page).to have_h1("Upload file")
    expect(page).to have_element(:div, text: "You need to fix 2 errors related to specific rows", class: "govuk-error-summary")
    expect(page).to have_element(:td, text: "Enter a valid school URN", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Enter a valid subject code", class: "govuk-table__cell")
    expect(page).to have_element(:p, text: "Only showing rows with errors", class: "govuk-!-text-align-centre")
    expect(page).to have_link("Upload your file again", class: "govuk-button")
    expect(page).to have_link("Cancel", href: "/admin_dashboard")
  end
end
