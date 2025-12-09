require "rails_helper"

RSpec.describe "Admin user imports previous placement register data", type: :system do
  scenario do
    given_schools_exist
    and_placement_subjects_exist
    and_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_click_on_import_register_itt_placement_data
    then_i_see_the_csv_upload_page

    when_i_upload_a_csv_containing_valid_register_data
    and_i_click_on_upload
    then_i_see_the_confirmation_page

    when_i_click_on_confirm_upload
    then_i_see_the_admin_dashboard
    and_i_see_a_success_message
  end

  private

  def given_schools_exist
    @school = create(:school, urn: 100003)
  end

  def and_placement_subjects_exist
    @placement_subject = create(:placement_subject, name: "Computing", code: "11")
  end
  def and_i_am_signed_in
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

  def then_i_see_the_confirmation_page
    expect(page).to have_title("Confirm you want to upload previous placements - Import Register ITT Placement Data - Find placement schools")
    expect(page).to have_caption("Import Register ITT Placement Data")
    expect(page).to have_h1("Confirm you want to upload previous placements")
    expect(page).to have_h2("Preview of import.csv")
    expect(page).to have_table_row(
      "1" => "2",
      "academic_year_start_date" => "2025-09-01",
      "school_urn" => "100003",
      "subject_name" => "Computing",
    )
    expect(page).to have_element(
      :p,
      text: "Showing all rows",
      class: "govuk_body govuk-!-text-align-centre secondary-text",
    )
    expect(page).to have_button("Confirm upload")
    expect(page).to have_link("Cancel", href: "/admin_dashboard")
  end

  def when_i_click_on_confirm_upload
    click_on "Confirm upload"
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner(
      "Register ITT placement data uploaded",
      "It may take a moment for the data to import."
    )
  end
end
