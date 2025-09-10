class ServiceNavigationComponent < ApplicationComponent
  def initialize(current_user:, current_organisation:)
    @current_user = current_user
    @current_organisation = current_organisation
  end

  def navigation_items
    if current_user && current_organisation
      case current_organisation
      when School
        [
          {
            text: t("components.service_navigation_component.placement_information"),
            href: helpers.placement_preferences_path,
            active: helpers.current_page?(helpers.placement_preferences_path),
            current: helpers.current_page?(helpers.placement_preferences_path)
          },
          {
            text: t("components.service_navigation_component.organisation_details"),
            href: helpers.organisation_path(current_organisation.id),
            active: helpers.current_page?(helpers.organisation_path(current_organisation.id)),
            current: helpers.current_page?(helpers.organisation_path(current_organisation.id))
          }
        ]
      when Provider
        [
          {
            text: t("components.service_navigation_component.find_placements"),
            href: helpers.organisations_path,
            active: helpers.current_page?(helpers.organisations_path),
            current: helpers.current_page?(helpers.organisations_path)
          },
          {
            text: t("components.service_navigation_component.organisation_details"),
            href: helpers.organisation_path(current_organisation.id),
            active: helpers.current_page?(helpers.organisation_path(current_organisation.id)),
            current: helpers.current_page?(helpers.organisation_path(current_organisation.id))
          }
        ]
      else
        []
      end
    else
      []
    end
  end

  def service_name
    I18n.t(".service.name")
  end

  private

  attr_reader :current_user, :current_organisation
end
