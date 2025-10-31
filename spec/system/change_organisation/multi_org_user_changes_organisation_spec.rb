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
    @current_academic_year = create(:academic_year, :current)
    @current_academic_year_name = @current_academic_year.name
    @next_academic_year = create(:academic_year, :next)
    @next_academic_year_name = @next_academic_year.name
    @hogwarts = build(:school, name: "Hogwarts")
    @order_of_the_phoenix = build(:provider, name: "Order of the Phoenix")

    sign_in_user(organisations: [ @hogwarts, @order_of_the_phoenix ])
  end

  def then_i_see_the_change_organisation_page
    expect(page).to have_title("Change organisation")
    expect(page).to have_h1("Change organisation")
    expect(page).to have_h2("Schools")
    expect(page).to have_summary_list_row("Hogwarts", expected_action: "Change")
    expect(page).to have_link("Change", href: "/change_organisation/#{@hogwarts.id}/update_organisation")
    expect(page).to have_h2("Providers")
    expect(page).to have_summary_list_row("Order of the Phoenix", expected_action: "Change")
    expect(page).to have_link("Change", href: "/change_organisation/#{@order_of_the_phoenix.id}/update_organisation")
  end

  def when_i_select_hogwarts
    click_link "Change Hogwarts"
  end

  def then_i_see_the_placement_preferences_form_page
    expect(page).to have_title(
                      "For which academic year are you providing information about placements for trainee teachers? - Find placement schools",
                      )
    expect(page).to have_caption("Placement information")
    expect(page).to have_element(
                      :legend,
                      text: "For which academic year are you providing information about placements for trainee teachers?",
                      class: "govuk-fieldset__legend",
                      )
    expect(page).to have_field(@current_academic_year_name, type: :radio)
    expect(page).to have_field(@next_academic_year_name, type: :radio)
  end

  def when_i_click_on_hogwarts_change_organisation_link
    click_link "Hogwarts (change)"
  end

  def when_i_select_order_of_the_phoenix
    click_link "Change Order of the Phoenix"
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
