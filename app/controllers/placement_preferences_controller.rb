class PlacementPreferencesController < ApplicationController
  def index
    @placement_preferences = PlacementPreference.where(organisation: current_organisation)

    render locals: { placement_preferences: @placement_preferences, organisation: current_organisation }
  end
end
