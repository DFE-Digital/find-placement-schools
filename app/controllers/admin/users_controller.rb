class Admin::UsersController < AdminController
  before_action :user, only: %i[show remove destroy]
  before_action :authorize_user

  def index
    @pagy, @users = pagy(User.admin)
  end

  def show; end

  def remove; end

  def destroy
    user.destroy

    redirect_to admin_users_path, flash: {
      success: true,
      heading: t(".success")
    }
  end

  private

  def user
    @user ||= User.admin.find(params.require(:id))
  end

  def authorize_user
    authorize @user || User
  end
end
