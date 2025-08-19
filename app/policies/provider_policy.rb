class ProviderPolicy < ApplicationPolicy
  def show?
    user.selected_organisation == record
  end
end
