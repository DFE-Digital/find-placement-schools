class AdminDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index; end

  private

  def require_admin
    unless current_user&.admin?
      head :forbidden
    end
  end
end
