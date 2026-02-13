require "smoke_tests/smoke_test_helper"

RSpec.describe "Home Page", :smoke_test, service: :claims, type: :system do
  it "User visits the homepage" do
    given_i_am_on_the_start_page
    i_can_see_the_service_name
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def i_can_see_the_service_name
    within ".govuk-service-navigation__service-name" do
      expect(page).to have_element(:span, text: "Find placement schools", class: "govuk-service-navigation__text")
    end
  end
end
