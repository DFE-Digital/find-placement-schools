class UserPolicy < ApplicationPolicy
  def new?
    true
  end

  def show?
    user.admin? || user.selected_organisation.users.include?(record)
  end

  def index?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def remove?
    return false if record == user
    user.admin? || user.selected_organisation.users.include?(record)
  end

  def destroy?
    return false if record == user
    user.admin? || user.selected_organisation.users.include?(record)
  end


  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.admin?

      memberships = UserMembership.where(organisation: user.selected_organisation)
      scope.where(id: memberships.select(:user_id))
    end
  end
end
