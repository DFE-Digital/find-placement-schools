class SessionsController < ApplicationController
  def new; end

  def callback
    user = User.find_by(email_address: params[:email_address], first_name: params[:first_name], last_name: params[:last_name])
    session[:user_id] = user.id
    user.update!(last_signed_in_at: Time.current)

    redirect_to sign_in_path, notice: "Signed in as #{user.first_name} #{user.last_name}"
  end

  def destroy
    session.clear
    redirect_to personas_path
  end
end
