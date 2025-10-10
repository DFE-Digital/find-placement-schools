class UsersController < ApplicationController
  before_action :user, only: %i[show remove destroy]
  before_action :authorize_user

  def index
    @pagy, @users = pagy(current_organisation.users)
  end

  def show; end

  def remove; end

  def destroy
    Users::Remove.call(user:, organisation: current_organisation)

    redirect_to users_path(current_organisation), flash: {
      success: true,
      heading: t(".success")
    }
  end

  private

  def user
    @user ||= current_organisation.users.find(params.require(:id))
  end

  def authorize_user
    authorize @user || User
  end
end
