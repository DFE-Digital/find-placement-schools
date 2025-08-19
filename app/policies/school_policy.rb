class SchoolPolicy < ApplicationPolicy
  def show?
    selected_organisation = user.selected_organisation

    selected_organisation == record ||
      selected_organisation.is_a?(Provider)
  end
end
