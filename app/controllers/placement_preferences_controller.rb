class PlacementPreferencesController < ApplicationController
  def index
    @placement_preferences = current_organisation
      .placement_preferences
      .joins(:academic_year)
      .order("academic_years.starts_on")

    render locals: { placement_preferences: @placement_preferences, organisation: current_organisation }
  end

  def show
    @placement_preference = current_organisation.placement_preferences.find(params[:id]).decorate
  end
end
