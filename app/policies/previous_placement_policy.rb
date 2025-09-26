class PreviousPlacementPolicy < ApplicationPolicy
  def new?
    user.admin?
  end
  alias_method :edit?, :new?
  alias_method :update?, :new?
end
