class Organisations::UrgentPlacementsBroadcastController < ApplicationController
  include WizardController

  before_action :set_provider
  before_action :set_wizard

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.broadcast_to_schools
      flash = {
        success: true,
        heading: t(".heading"),
        body: t(
          ".body",
          location: @wizard.location,
          radius: @wizard.radius,
          count: @wizard.schools.size,
          date: l(
            Date.current.beginning_of_week(:friday) + 1.week,
            format: :long_with_day,
          ),
        ),
      }
      @wizard.reset_state

      redirect_to index_path, flash:
    end
  end

  private

  def set_provider
    @provider = current_organisation
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = UrgentPlacementBroadcastWizard.new(
      current_user:,
      provider: @provider,
      params:,
      state:,
      current_step:,
      )
  end

  def step_path(step)
    urgent_placements_organisations_path(state_key:, step:)
  end

  def index_path
    organisations_path
  end
end