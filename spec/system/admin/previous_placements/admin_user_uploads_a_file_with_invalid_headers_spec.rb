require "rails_helper"

RSpec.describe "Admin user does not upload a CSV file", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_admin_dashboard

    when_i_click_on_import_register_itt_placement_data
    then_i_see_the_csv_upload_page

    when_i_upload_an_invalid_file
    and_i_click_on_upload
    then_i_see_validation_error_regarding_invalid_headers
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

  def when_i_upload_an_invalid_file
    attach_file "Upload CSV file", "spec/fixtures/gias/gias_subset.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_validation_error_regarding_invalid_headers
    expect(page).to have_css(
      ".govuk-error-summary__list",
      text: "Your file needs a column called ‘academic_year_start_date’, ‘school_urn’, and ‘subject_name’.",
    )
    expect(page).to have_css(
      ".govuk-error-summary__list",
      text: "Right now it has columns called ‘URN’, ‘LA (code)’, ‘LA (name)’, ‘EstablishmentNumber’, ‘EstablishmentName’," \
        " ‘TypeOfEstablishment (code)’, ‘TypeOfEstablishment (name)’, ‘EstablishmentTypeGroup (code)’, ‘EstablishmentTypeGroup (name)’," \
        " ‘EstablishmentStatus (code)’, ‘EstablishmentStatus (name)’, ‘ReasonEstablishmentOpened (code)’, ‘ReasonEstablishmentOpened (name)’,"\
        " ‘OpenDate’, ‘ReasonEstablishmentClosed (code)’, ‘ReasonEstablishmentClosed (name)’, ‘CloseDate’, ‘PhaseOfEducation (code)’," \
        " ‘PhaseOfEducation (name)’, ‘StatutoryLowAge’, ‘StatutoryHighAge’, ‘Boarders (code)’, ‘Boarders (name)’, ‘NurseryProvision (name)’," \
        " ‘OfficialSixthForm (code)’, ‘OfficialSixthForm (name)’, ‘Gender (code)’, ‘Gender (name)’, ‘ReligiousCharacter (code)’," \
        " ‘ReligiousCharacter (name)’, ‘ReligiousEthos (name)’, ‘Diocese (code)’, ‘Diocese (name)’, ‘AdmissionsPolicy (code)’," \
        " ‘AdmissionsPolicy (name)’, ‘SchoolCapacity’, ‘SpecialClasses (code)’, ‘SpecialClasses (name)’, ‘CensusDate’, ‘NumberOfPupils’," \
        " ‘NumberOfBoys’, ‘NumberOfGirls’, ‘PercentageFSM’, ‘TrustSchoolFlag (code)’, ‘TrustSchoolFlag (name)’, ‘Trusts (code)’," \
        " ‘Trusts (name)’, ‘SchoolSponsorFlag (name)’, ‘SchoolSponsors (name)’, ‘FederationFlag (name)’, ‘Federations (code)’," \
        " ‘Federations (name)’, ‘UKPRN’, ‘FEHEIdentifier’, ‘FurtherEducationType (name)’, ‘OfstedLastInsp’," \
        " ‘OfstedSpecialMeasures (code)’, ‘OfstedSpecialMeasures (name)’, ‘LastChangedDate’, ‘Street’, ‘Locality’, ‘Address3’," \
        " ‘Town’, ‘County (name)’, ‘Postcode’, ‘SchoolWebsite’, ‘TelephoneNum’, ‘HeadTitle (name)’, ‘HeadFirstName’, ‘HeadLastName’," \
        " ‘HeadPreferredJobTitle’, ‘BSOInspectorateName (name)’, ‘InspectorateReport’, ‘DateOfLastInspectionVisit’, ‘NextInspectionVisit’," \
        " ‘TeenMoth (name)’, ‘TeenMothPlaces’, ‘CCF (name)’, ‘SENPRU (name)’, ‘EBD (name)’, ‘PlacesPRU’, ‘FTProv (name)’, ‘EdByOther (name)’," \
        " ‘Section41Approved (name)’, ‘SEN1 (name)’, ‘SEN2 (name)’, ‘SEN3 (name)’, ‘SEN4 (name)’, ‘SEN5 (name)’, ‘SEN6 (name)’, ‘SEN7 (name)’," \
        " ‘SEN8 (name)’, ‘SEN9 (name)’, ‘SEN10 (name)’, ‘SEN11 (name)’, ‘SEN12 (name)’, ‘SEN13 (name)’, ‘TypeOfResourcedProvision (name)’," \
        " ‘ResourcedProvisionOnRoll’, ‘ResourcedProvisionCapacity’, ‘SenUnitOnRoll’, ‘SenUnitCapacity’, ‘GOR (code)’, ‘GOR (name)’," \
        " ‘DistrictAdministrative (code)’, ‘DistrictAdministrative (name)’, ‘AdministrativeWard (code)’, ‘AdministrativeWard (name)’," \
        " ‘ParliamentaryConstituency (code)’, ‘ParliamentaryConstituency (name)’, ‘UrbanRural (code)’, ‘UrbanRural (name)’, ‘GSSLACode (name)’," \
        " ‘Easting’, ‘Northing’, ‘MSOA (name)’, ‘LSOA (name)’, ‘InspectorateName (name)’, ‘SENStat’, ‘SENNoStat’, ‘BoardingEstablishment (name)’," \
        " ‘PropsName’, ‘PreviousLA (code)’, ‘PreviousLA (name)’, ‘PreviousEstablishmentNumber’, ‘OfstedRating (name)’, ‘RSCRegion (name)’," \
        " ‘Country (name)’, ‘UPRN’, ‘SiteName’, ‘QABName (code)’, ‘QABName (name)’, ‘EstablishmentAccredited (code)’, ‘EstablishmentAccredited (name)’," \
        " ‘QABReport’, ‘CHNumber’, ‘MSOA (code)’, ‘LSOA (code)’, ‘FSM’, and ‘AccreditationExpiryDate’.",
    )
  end
end
