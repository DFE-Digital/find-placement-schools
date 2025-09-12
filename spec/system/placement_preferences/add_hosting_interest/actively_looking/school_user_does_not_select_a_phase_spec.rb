require "rails_helper"

RSpec.describe "School user does not select a phase", type: :system do
  scenario do
    given_academic_years_exist
    when_i_am_signed_in
    then_i_see_the_appetite_form_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_education_phase_form_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_phase
  end

  private

  def when_i_am_signed_in
    @school = build(:school, name: "Hogwarts")
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

  def then_i_see_the_education_phase_form_page
    expect(page).to have_title(
      "What education phase or specialism can your school offer placements in? - Find placement schools",
    )
    expect(page).to have_caption("Placement information #{@next_academic_year_short_name}")
    expect(page).to have_element(
      :legend,
      text: "What education phase or specialism can your school offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_hint("Select all that apply")
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field(
      "Special educational needs and disabilities (SEND) specific",
      type: :checkbox,
    )
  end

  def then_i_see_a_validation_error_for_selecting_a_phase
    expect(page).to have_validation_error(
      "Please select which phase you are looking to host placements at",
    )
  end
end
