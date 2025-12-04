require "rails_helper"

RSpec.describe ServiceNavigationComponent, type: :component do
  context "when the user is not signed in" do
    it "renders an empty navigation" do
      render_inline ServiceNavigationComponent.new(current_user: nil, current_organisation: nil)

      expect(page).not_to have_content("Placement information")
      expect(page).not_to have_content("Organisation details")
      expect(page).not_to have_content("Users")
    end
  end

  context "when the user is signed in but has no organisation" do
    let(:current_user) { create(:user) }

    it "renders an empty navigation" do
      render_inline ServiceNavigationComponent.new(current_user:, current_organisation: nil)

      expect(page).not_to have_content("Placement information")
      expect(page).not_to have_content("Organisation details")
      expect(page).not_to have_content("Users")
    end
  end

  context "when the user is signed in with a provider organisation" do
    let(:current_user) { create(:user) }
    let(:current_organisation) { create(:provider) }

    it "renders the service navigation with the correct items" do
      render_inline ServiceNavigationComponent.new(current_user:, current_organisation:)

      expect(page).to have_content("Find placements")
      expect(page).to have_link("Find placements", href: "/organisations")
      expect(page).to have_content("Provider details")
      expect(page).to have_link("Provider details", href: "/organisations/#{current_organisation.id}")
      expect(page).to have_content("Users")
      expect(page).to have_link("Users", href: "/users")
    end
  end

  context "when the user is signed in with a school organisation" do
    let(:current_user) { create(:user) }
    let(:current_organisation) { create(:school) }

    it "renders the service navigation with the correct items" do
      render_inline ServiceNavigationComponent.new(current_user:, current_organisation:)

      expect(page).to have_content("Placement information")
      expect(page).to have_link("Placement information", href: "/placement_preferences")
      expect(page).to have_content("School details")
      expect(page).to have_link("School details", href: "/organisations/#{current_organisation.id}")
      expect(page).to have_content("Users")
      expect(page).to have_link("Users", href: "/users")
    end
  end

  context "when the user is signed in as an admin user" do
    let(:current_user) { create(:user, :admin) }
    let(:current_organisation) { nil }

    it "renders the service navigation with the correct items" do
      render_inline ServiceNavigationComponent.new(current_user:, current_organisation:)

      expect(page).to have_content("Dashboard")
      expect(page).to have_link("Dashboard", href: "/admin_dashboard")
      expect(page).to have_content("Users")
      expect(page).to have_link("Users", href: "/admin/users")
    end
  end
end
