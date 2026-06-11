class PlacementPreferencesController < ApplicationController
  def index
    academic_years = AcademicYear.for_display
    render locals: { academic_years:, organisation: current_organisation }
  end

  def show
    @placement_preference = current_organisation.placement_preferences.find(params[:id]).decorate
  end
end
