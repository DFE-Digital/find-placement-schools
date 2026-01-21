require "rails_helper"

RSpec.describe "School user views their colleagues", type: :system do
  scenario do
    given_that_schools_exist_with_users
    and_i_am_signed_in
    then_i_see_the_appetite_page

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page
    and_i_see_my_colleagues
  end

  private

  def given_that_schools_exist_with_users
    @current_academic_year = AcademicYear.current.decorate
    @hogwarts = create(:school, name: "Hogwarts")
    @harry = create(:user, first_name: "Harry", last_name: "Potter", email_address: "harry.potter@hogwarts.com", organisations: [ @hogwarts ])
    @ron = create(:user, first_name: "Ron", last_name: "Weasley", email_address: "ron.weasley@hogwarts.com", organisations: [ @hogwarts ])
  end

  def and_i_am_signed_in
    sign_in_user(organisations: [ @hogwarts ])
  end

  def then_i_see_the_appetite_page
    expect(page).to have_title(
                      "Can your school offer placements for trainee teachers in the #{@current_academic_year.name} academic year? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "Can your school offer placements for trainee teachers in the #{@current_academic_year.name} academic year?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("Maybe", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_navigate_to_the_users_tab
    within service_navigation do
      click_on "Users"
    end
  end

  def then_i_see_the_users_page
    expect(page).to have_title("Users - Find placement schools")
    expect(service_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
  end

  def and_i_see_my_colleagues
    expect(page).to have_table_row({
      "Full name" => "Harry Potter",
      "Email" => "harry.potter@hogwarts.com"
    })

    expect(page).to have_table_row({
      "Full name" => "Ron Weasley",
      "Email" => "ron.weasley@hogwarts.com"
    })
  end
end
