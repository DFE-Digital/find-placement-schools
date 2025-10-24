class Admin::Users::OnboardUsersController < ApplicationController
  include WizardController

  before_action :set_wizard
  before_action :authorize_user

  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.upload_users
      @wizard.reset_state
      redirect_to index_path, flash: {
        success: true,
        heading: t(".success.heading"),
        body: t(".success.body")
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = ::OnboardUsersWizard.new(params:, state:, current_step:)
  end

  def authorize_user
    authorize User, :new?
  end

  def index_path
    admin_dashboard_index_path
  end

  def step_path(step)
    onboard_users_admin_users_path(state_key:, step:)
  end
end
