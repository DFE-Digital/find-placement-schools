class ServiceNavigationComponent < ApplicationComponent
  def initialize(current_user:, current_organisation:)
    @current_user = current_user
    @current_organisation = current_organisation
  end

  def navigation_items
    if current_user&.admin? && !current_organisation
      [
        {
          text: t("components.service_navigation_component.dashboard"),
          href: helpers.admin_dashboard_index_path,
          active: request.path.match?(/^\/admin_dashboard/),
          current: request.path.match?(/^\/admin_dashboard/)
        },
        {
          text: t("components.service_navigation_component.users"),
          href: helpers.admin_users_path,
          active: request.path.match?(/^\/admin\/users/),
          current: request.path.match?(/^\/admin\/users/)
        }
      ]
    elsif current_user && current_organisation
      case current_organisation
      when School
        [
          {
            text: t("components.service_navigation_component.placement_information"),
            href: helpers.placement_preferences_path,
            active: request.path.match?(/^\/placement_preferences/),
            current: request.path.match?(/^\/placement_preferences/)
          },
          {
            text: t("components.service_navigation_component.users"),
            href: helpers.users_path,
            active: request.path.match?(/^\/users/),
            current: request.path.match?(/^\/users/)
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
            active: request.path.match?(/^\/organisation/) && !helpers.current_page?(helpers.organisation_path(current_organisation.id)),
            current: request.path.match?(/^\/organisation/) && !helpers.current_page?(helpers.organisation_path(current_organisation.id))
          },
          {
            text: t("components.service_navigation_component.users"),
            href: helpers.users_path,
            active: request.path.match?(/^\/users/),
            current: request.path.match?(/^\/users/)
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
