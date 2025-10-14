class Users::AddUserController < ApplicationController
  include WizardController

  before_action :set_wizard
  before_action :authorize_user

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      user = @wizard.create_user
      Users::Invite.call(user:, organisation: current_organisation)
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
        body: t(".success_body", user_name: user.first_name, school_name: current_organisation.name),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = AddUserWizard.new(organisation: current_organisation, params:, state:, current_step:)
  end

  def authorize_user
    authorize User
  end

  def step_path(step)
    add_user_users_path(state_key:, step:)
  end

  def index_path
    users_path(@school)
  end
end
