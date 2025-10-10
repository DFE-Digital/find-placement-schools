require "rails_helper"

RSpec.describe "Provider user views their colleagues", type: :system do
  scenario do
    given_that_providers_exist_with_users
    and_i_am_signed_in
    then_i_see_the_find_placements_page

    when_i_navigate_to_the_users_tab
    then_i_see_the_users_page
    and_i_see_my_colleagues
  end

  private

  def given_that_providers_exist_with_users
    @order_of_the_phoenix = create(:provider, name: "Order of the Phoenix")
    @sirius = create(:user, first_name: "Sirius", last_name: "Black", email_address: "sirius.black@ootp.com", organisations: [ @order_of_the_phoenix ])
    @remus = create(:user, first_name: "Remus", last_name: "Lupin", email_address: "remus.lupin@ootp.com", organisations: [ @order_of_the_phoenix ])
  end

  def and_i_am_signed_in
    sign_in_user(organisations: [ @order_of_the_phoenix ])
  end

  def then_i_see_the_find_placements_page
    expect(page).to have_title("Find placements - Find placement schools")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_h1("Find placements")
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
      "Full name" => "Sirius Black",
      "Email" => "sirius.black@ootp.com"
    })

    expect(page).to have_table_row({
      "Full name" => "Remus Lupin",
      "Email" => "remus.lupin@ootp.com"
    })
  end
end
