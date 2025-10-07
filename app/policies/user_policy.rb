class UserPolicy < ApplicationPolicy
  def new?
    true
  end

  def show?
    user.selected_organisation.users.include?(record)
  end

  def index?
    true
  end

  def edit?
    user.selected_organisation.users.include?(record)
  end

  def update?
    user.selected_organisation.users.include?(record)
  end

  def destroy?
    record != user && user.selected_organisation.users.include?(record)
  end


  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.admin?

      memberships = UserMembership.where(organisation: user.selected_organisation)
      scope.where(id: memberships.select(:user_id))
    end
  end
end
