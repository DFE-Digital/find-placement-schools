class UrgentPlacementBroadcastWizard::SchoolResultsStep < BaseStep
  delegate :location, :radius, to: :location_search_step

  def schools
    @schools ||= SchoolsQuery.call(params: {
      location_coordinates:,
      radius:
    })
  end

  def first_25_schools
    @first_25_schools ||= schools.first(25)
  end

  def map_coordinates
    if schools.size > 1
      location_coordinates
    else
      school = schools.first
      [ school.latitude, school.longitude ]
    end
  end

  def next_email_date
    Date.current.beginning_of_week(:friday) + 1.week
  end

  private

  def location_coordinates
    @location_coordinates ||= Geocoder::Search.call(location).coordinates
  end

  def location_search_step
    @location_search_step ||= wizard.steps.fetch(:location_search)
  end
end
