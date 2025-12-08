class PlacementPreferencesController < ApplicationController
  def index
    academic_years = AcademicYear.order(:starts_on).last(2)
    render locals: { academic_years:, organisation: current_organisation }
  end

  def show
    @placement_preference = current_organisation.placement_preferences.find(params[:id]).decorate
  end
end
