require "rails_helper"

RSpec.describe "School user updates the placement preference with an invalid value", type: :system do
  scenario do
    given_academic_years_exist
    and_secondary_subjects_exist
    and_a_placement_preference_exists
    when_i_am_signed_in
    then_i_see_the_placement_information_page

    when_i_click_on_the_next_academic_year
    then_i_see_the_school_is_not_offering_placements

    when_i_click_on_edit_placement_information
    then_i_see_the_appetite_form_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_school_contact_form_page

    when_i_fill_in_the_school_contact_details_with_an_invalid_email_address
    and_i_click_on_continue
    then_i_see_a_validation_error_for_entering_an_invalid_email_address
  end

  private

  def when_i_am_signed_in
    sign_in_user(organisations: [ @school ])
  end

  def given_academic_years_exist
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name
    @next_academic_year_short_name = "#{@next_academic_year.starts_on.year}/#{@next_academic_year.ends_on.strftime("%y")}"
  end

  def and_secondary_subjects_exist
    @english = create(:placement_subject, :secondary, name: "English")
    @science = create(:placement_subject, :secondary, name: "Science")
    @mathematics = create(:placement_subject, :secondary, name: "Mathematics")
  end

  def and_a_placement_preference_exists
    placement_details = {
      "appetite" => { "appetite" => "not_open" },
      "are_you_sure" => nil,
      "school_contact" => {
        "first_name" => "Joe",
        "last_name" => "Bloggs",
        "email_address" => "joe_bloggs@example.com"
      },
      "reason_not_hosting" => {
        "reasons_not_hosting" => [ "Working to improve our OFSTED rating" ],
        "other_reason_not_hosting" => ""
      }
    }
    @school = build(:school, name: "Hogwarts")
    @placement_preference = create(
      :placement_preference,
      appetite: :not_open,
      organisation: @school,
      academic_year: @next_academic_year,
      placement_details:,
      )
  end

  def then_i_see_the_placement_information_page
    expect(page).to have_caption("Hogwarts")
    expect(page).to have_h1("Placement information")

    expect(page).to have_element(:caption, text: "Placement information")
    expect(page).to have_table_row({
                                     "Academic year" => @next_academic_year_name,
                                     "Status" => "Not offering placements"
                                   })
  end

  def when_i_click_on_the_next_academic_year
    click_on @next_academic_year_name
  end

  def then_i_see_the_school_is_not_offering_placements
    expect(page).to have_title(
                      "What happens next? - Find placement schools",
                      )
    expect(page).to have_panel(
                      "Information added",
                      "Providers can see that your school is not offering placements for trainee teachers in the academic year #{@next_academic_year_short_name}",
                      )
    expect(page).to have_h1("What happens next?")
    expect(page).to have_paragraph(
                      "We will email the placement contact to ask if your school can offer placements for trainee teachers in future academic years: joe_bloggs@example.com",
                      )
    expect(page).to have_paragraph(
                      "If you would like to host placements this year, edit placement information for your school.",
                      )
    expect(page).to have_link(
                      "edit placement information",
                      href: new_edit_hosting_interest_placement_preference_path(@placement_preference)
                    )

    expect(page).to have_h3("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_edit_placement_information
    click_on "edit placement information"
  end

  def then_i_see_the_appetite_form_page
    expect(page).to have_title(
                      "Can your school offer placements for trainee teachers in the #{@next_academic_year_name} academic year? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "Can your school offer placements for trainee teachers in the #{@next_academic_year_name} academic year?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("Maybe", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_select_yes
    choose "Yes"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_school_contact_form_page
    expect(page).to have_title(
                      "Who should providers contact? - Find placement schools",
                      )
    expect(page).to have_caption("Placement contact")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_hint(
                      "Choose the person best placed to organise placements for trainee teachers at your school",
                      )
    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
  end

  def when_i_fill_in_the_school_contact_details_with_an_invalid_email_address
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs"
  end

  def then_i_see_a_validation_error_for_entering_an_invalid_email_address
    expect(page).to have_validation_error(
      "Enter an email address in the correct format, like name@example.com"
    )
  end
end
