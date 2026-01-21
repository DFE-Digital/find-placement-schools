class PlacementPreferences::AddHostingInterestController < ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard

  before_action :authorize_placement_preference

  attr_reader :school

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      placement_preference = @wizard.save_placement_preference
      School::UserMailer.user_feedback_request_notification(current_user).deliver_later
      @wizard.reset_state

      redirect_to placement_preference_path(placement_preference)
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = AddHostingInterestWizard.new(
      current_user:,
      school:,
      academic_year:,
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    add_hosting_interest_placement_preferences_path(state_key:, step:)
  end

  def index_path
    placement_preferences_path(@school)
  end

  def set_school
    @school ||= current_organisation
  end

  def academic_year
    @academic_year ||= if params[:academic_year_id].present?
      AcademicYear.find(params[:academic_year_id])
    else
      AcademicYear.current
    end
  end

  def authorize_placement_preference
    authorize PlacementPreference.new, :new?
  end
end
