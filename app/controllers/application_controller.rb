class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  include Pagy::Backend
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  helper_method :current_user, :current_organisation, :user_signed_in?

  def current_user
    @current_user ||= DfeSignInUser.load_from_session(session)&.user
  end

  def current_organisation
    return if (@current_user&.selected_organisation).blank?

    @current_organisation ||= Organisation.find(@current_user.selected_organisation_id)
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

  # Not currently using this method, but keeping it for future use
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

  private

  def user_not_authorized
    flash[:heading] = "You are not authorized to perform this action."
    flash[:success] = false

    redirect_back(fallback_location: root_path)
  end
end
