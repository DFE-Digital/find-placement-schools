require "rails_helper"

RSpec.describe "Multi org user changes organisation", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_change_organisation_page

    when_i_select_hogwarts
    then_i_see_the_placement_preferences_form_page

    when_i_click_on_hogwarts_change_organisation_link
    then_i_see_the_change_organisation_page

    when_i_select_order_of_the_phoenix
    then_i_see_the_find_placements_page_for_order_of_the_phoenix
  end

  private

  def given_i_am_signed_in
    @hogwarts = build(:school, name: "Hogwarts")
    @order_of_the_phoenix = build(:provider, name: "Order of the Phoenix")

    sign_in_user(organisations: [ @hogwarts, @order_of_the_phoenix ])
  end

  def then_i_see_the_change_organisation_page
    expect(page).to have_title("Change organisation")
    expect(page).to have_h1("Change organisation")
    expect(page).to have_h2("Schools")
    expect(page).to have_summary_list_row("Hogwarts", expected_action: "Continue")
    expect(page).to have_link("Continue", href: "/change_organisation/#{@hogwarts.id}/update_organisation")
    expect(page).to have_h2("Providers")
    expect(page).to have_summary_list_row("Order of the Phoenix", expected_action: "Continue")
    expect(page).to have_link("Continue", href: "/change_organisation/#{@order_of_the_phoenix.id}/update_organisation")
  end

  def when_i_select_hogwarts
    click_link "Continue Hogwarts"
  end

  def then_i_see_the_placement_preferences_form_page
    expect(page).to have_title("Can your school offer placements for trainee teachers in the 2025 to 2026 academic year? - Find placement schools")
    expect(page).to have_important_banner("You have changed your organisation to Hogwarts")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in the 2025 to 2026 academic year?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("Maybe", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_click_on_hogwarts_change_organisation_link
    click_link "Hogwarts (change)"
  end

  def when_i_select_order_of_the_phoenix
    click_link "Continue Order of the Phoenix"
  end

  def then_i_see_the_find_placements_page_for_order_of_the_phoenix
    expect(page).to have_title("Find placements")
    expect(page).to have_link("Order of the Phoenix (change)", href: "/change_organisation")
    expect(service_navigation).to have_current_item("Find placements")
    expect(page).to have_important_banner("You have changed your organisation to Order of the Phoenix")
    expect(page).to have_h1("Find placements")
  end

  def when_i_click_on_order_of_the_phoenix_organisation_link
    click_link "Order of the Phoenix (change)"
  end
end
