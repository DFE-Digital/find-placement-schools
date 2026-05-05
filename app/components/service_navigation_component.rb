class ServiceNavigationComponent < ApplicationComponent
  def initialize(current_user:, current_organisation:)
    @current_user = current_user
    @current_organisation = current_organisation
  end

  def navigation_items
    items = primary_navigation_items
    items + auth_navigation_items
  end

  private

  attr_reader :current_user, :current_organisation

  def primary_navigation_items
    if current_user&.admin? && !current_organisation
      [
        {
          text: t("components.service_navigation_component.dashboard"),
          href: helpers.admin_dashboard_index_path,
          active: matches_admin_dashboard_path?,
          current: matches_admin_dashboard_path?
        },
        {
          text: t("components.service_navigation_component.users"),
          href: helpers.admin_users_path,
          active: matches_admin_users_path?,
          current: matches_admin_users_path?
        }
      ]
    elsif current_user && current_organisation
      case current_organisation
      when School
        [
          {
            text: t("components.service_navigation_component.placement_information"),
            href: helpers.placement_preferences_path,
            active: matches_placement_information_path?,
            current: matches_placement_information_path?
          },
          {
            text: t("components.service_navigation_component.users"),
            href: helpers.users_path,
            active: matches_users_path?,
            current: matches_users_path?
          },
          {
            text: t("components.service_navigation_component.school_details"),
            href: helpers.organisation_path(current_organisation.id),
            active: matches_organisation_details_path?,
            current: matches_organisation_details_path?
          }
        ]
      when Provider
        [
          {
            text: t("components.service_navigation_component.find_placements"),
            href: helpers.organisations_path,
            active: matches_find_placements_path?,
            current: matches_find_placements_path?
          },
          {
            text: t("components.service_navigation_component.users"),
            href: helpers.users_path,
            active: matches_users_path?,
            current: matches_users_path?
          },
          {
            text: t("components.service_navigation_component.provider_details"),
            href: helpers.organisation_path(current_organisation.id),
            active: matches_organisation_details_path?,
            current: matches_organisation_details_path?
          }
        ]
      else
        []
      end
    else
      []
    end
  end

  def auth_navigation_items
    return [] unless current_user

    items = []

    if current_organisation.present? && current_user.admin?
      items << {
        text: "#{current_organisation.name} (return to dashboard)",
        href: helpers.return_to_dashboard_admin_change_organisation_index_path
      }
    end

    if current_organisation.present? && current_user.organisations.count > 1
      items << {
        text: "#{current_organisation.name} (change)",
        href: helpers.change_organisation_index_path
      }
    end

    items << { text: "Sign out", href: helpers.sign_out_path }

    items
  end

  def service_name
    I18n.t(".service.name")
  end


  def matches_find_placements_path?
    request.path.match?(/^\/organisation/) && !helpers.current_page?(helpers.organisation_path(current_organisation.id))
  end

  def matches_users_path?
    request.path.match?(/^\/users/)
  end

  def matches_organisation_details_path?
    helpers.current_page?(helpers.organisation_path(current_organisation.id))
  end

  def matches_placement_information_path?
    request.path.match?(/^\/placement_preferences/)
  end

  def matches_admin_dashboard_path?
    request.path.match?(/^\/admin_dashboard/)
  end

  def matches_admin_users_path?
    request.path.match?(/^\/admin\/users/)
  end
end
