require "rails_helper"

RSpec.describe "School user views their colleagues", type: :system do
  scenario do
    given_that_schools_exist_with_users
    and_i_am_signed_in
    then_i_see_the_academic_years_page

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page
    and_i_see_my_colleagues
  end

  private

  def given_that_schools_exist_with_users
    @next_academic_year = AcademicYear.next.decorate
    @hogwarts = create(:school, name: "Hogwarts")
    @harry = create(:user, first_name: "Harry", last_name: "Potter", email_address: "harry.potter@hogwarts.com", organisations: [ @hogwarts ])
    @ron = create(:user, first_name: "Ron", last_name: "Weasley", email_address: "ron.weasley@hogwarts.com", organisations: [ @hogwarts ])
  end

  def and_i_am_signed_in
    sign_in_user(organisations: [ @hogwarts ])
  end

  def then_i_see_the_academic_years_page
    expect(page).to have_title(
                      "Which academic year do you want to add placement information for? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "Which academic year do you want to add placement information for?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field(@next_academic_year_name, type: :radio)
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
