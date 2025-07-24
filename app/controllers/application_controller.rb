class ApplicationController < ActionController::Base
  include Pagy::Backend

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  helper_method :user_signed_in?

  def current_user
    @current_user ||= DfeSignInUser.load_from_session(session)&.user
  end

  def user_signed_in?
    current_user.present?
  end

  def sign_in_user
    @sign_in_user ||= DfeSignInUser.load_from_session(session)
  end

  def redirect_if_signed_in
    redirect_to after_sign_in_path if user_signed_in?
  end

  def authenticate_user!
    return if current_user

    session["requested_path"] = request.fullpath

    redirect_to sign_in_path
  end

  def after_sign_in_path
    if requested_path.present?
      requested_path
    elsif current_user.admin
      # This should change
      root_path
    else
      # This should change
      root_path
    end
  end

  def requested_path
    return if [ sign_in_path, sign_out_path ].include?(session["requested_path"])

    @requested_path ||= session.delete("requested_path")
  end

  def after_sign_out_path
    sign_in_path
  end
end
