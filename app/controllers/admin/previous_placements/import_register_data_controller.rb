class Admin::PreviousPlacements::ImportRegisterDataController < ApplicationController
  include WizardController

  before_action :set_wizard

  before_action :authorize_previous_placement

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.import_previous_placements
      @wizard.reset_state

      redirect_to admin_dashboard_index_path, flash: {
        heading: t(".success.heading"),
        body: t(".success.body"),
        success: true
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = ImportPreviousPlacementsWizard.new(
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    import_register_data_admin_previous_placements_path(state_key:, step:)
  end

  def index_path
    admin_dashboard_index_path
  end

  def authorize_previous_placement
    authorize PreviousPlacement.new
  end
end
