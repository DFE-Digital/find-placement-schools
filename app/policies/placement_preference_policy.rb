class PlacementPreferencePolicy < ApplicationPolicy
  def new?
    user.selected_organisation.present?
  end

  def edit?
    user.selected_organisation == record.organisation
  end
end
