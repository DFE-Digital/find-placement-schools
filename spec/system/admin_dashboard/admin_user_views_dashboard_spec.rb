require "rails_helper"

RSpec.describe "Admin user views dashboard", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_admin_dashboard
  end

  scenario "in development" do
    allow(DevelopmentSeedData).to receive(:call)

    given_the_service_is_unlocked_for_development
    given_i_am_signed_in

    then_i_see_the_option_to_build_seed_data

    click_link "Build development seed data"

    then_i_remain_on_the_admin_dashboard
    then_the_development_seed_data_is_built
  end

  scenario "in az development" do
    allow(DevelopmentSeedData).to receive(:call)

    given_the_service_is_unlocked_for_az_development
    given_i_am_signed_in

    then_i_see_the_option_to_build_seed_data
  end

  private

  def given_the_service_is_unlocked_for_development
    allow(Rails.env).to receive(:development?).and_return(true)
    allow(HostingEnvironment.env).to receive(:az_development?).and_return(false)

    visit new_development_access_path
    fill_in "Password", with: "bat"
    click_button "Continue"
  end

  def given_the_service_is_unlocked_for_az_development
    allow(Rails.env).to receive(:development?).and_return(false)
    allow(HostingEnvironment.env).to receive(:az_development?).and_return(true)
  end

  def given_i_am_signed_in
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard
    expect(page).to have_title("Admin dashboard")
    expect(page).to have_h1("Admin dashboard")

    expect(page).to have_link("Mission control job dashboard", href: "/jobs")
    expect(page).to have_link("Import Register ITT Placement Data", href: "/admin/previous_placements/new")
  end

  def then_i_see_the_option_to_build_seed_data
    expect(page).to have_link("Build development seed data", href: build_development_seed_data_admin_dashboard_index_path)
  end

  def then_i_remain_on_the_admin_dashboard
    expect(page).to have_current_path("/admin_dashboard")
    expect(page).to have_content("Development seed data built")
  end

  def then_the_development_seed_data_is_built
    expect(DevelopmentSeedData).to have_received(:call).once
  end
end
