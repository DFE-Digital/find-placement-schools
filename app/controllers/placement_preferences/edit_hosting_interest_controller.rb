class PlacementPreferences::EditHostingInterestController < ApplicationController
  include WizardController

  before_action :set_placement_preference
  before_action :set_school
  before_action :set_wizard

  before_action :authorize_placement_preference

  attr_reader :school

  def new
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      placement_preference = @wizard.save_placement_preference
      @wizard.reset_state

      redirect_to placement_preference_path(placement_preference)
    end
  end

  private

  def set_placement_preference
    @placement_preference ||= PlacementPreference.find(params[:id])
  end

  def set_school
    @school ||= current_organisation
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = EditHostingInterestWizard.new(
      placement_preference: @placement_preference,
      current_user:,
      school:,
      params:,
      state:,
      current_step:,
    )
  end

  def authorize_placement_preference
    authorize @placement_preference, :edit?
  end

  def step_path(step)
    edit_hosting_interest_placement_preference_path(state_key:, step:)
  end

  def index_path
    placement_preference_path(@placement_preference)
  end
end
