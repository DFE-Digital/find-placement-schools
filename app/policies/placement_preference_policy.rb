class PlacementPreferencePolicy < ApplicationPolicy
  def new?
    user.selected_organisation.present?
  end
  alias_method :edit?, :new?
  alias_method :update?, :new?
end
