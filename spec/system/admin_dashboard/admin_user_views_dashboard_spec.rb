require "rails_helper"

RSpec.describe "Admin user views dashboard", type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_the_admin_dashboard
  end

  private

  def given_i_am_signed_in
    sign_in_admin_user
  end

  def then_i_see_the_admin_dashboard
    expect(page).to have_title("Admin dashboard")
    expect(page).to have_h1("Admin dashboard")

    expect(page).to have_link("Mission control job dashboard", href: "/jobs")
  end
end
