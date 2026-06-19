class DevelopmentAccessController < ApplicationController
  skip_before_action :ensure_development_password!
  skip_before_action :authenticate_user!

  def new; end

  def create
    if params.dig(:development_access, :password) == "bat"
      session["development_access_granted"] = true
      redirect_to(session.delete("requested_path_after_development_access") || root_path)
    else
      flash.now[:heading] = "Incorrect password"
      flash.now[:body] = "Enter the correct development password to continue."
      flash.now[:success] = false
      render :new, status: :unprocessable_entity
    end
  end
end
