class OrganisationsController < ApplicationController
  before_action :store_filter_params, only: %i[index]

  helper_method :location_coordinates, :academic_year

  def show
    @organisation = Organisation.find(params[:id])
    authorize @organisation

    if @organisation.is_a?(School)
      @organisation = @organisation.decorate
      academic_years = [ AcademicYear.current, AcademicYear.next ]

      @placement_by_academic_year = academic_years.each_with_object({}) do |year, h|
        placement_preference = @organisation.placement_preference_for(academic_year: year)&.decorate
        previous_placements = @organisation.previous_academic_years_hosted_placements(year)
        h[year] = {
          placement_preference:,
          placement_details: placement_preference&.placement_details,
          previous_placements:
        }
      end
    end

    render locals: {
      organisation: @organisation,
      placement_by_academic_year: @placement_by_academic_year
    }
  end

  def index
    schools = SchoolsQuery.call(params: query_params)
    pagy, schools = pagy(schools)
    @schools = schools.decorate
    calculate_travel_time

    render locals: { pagy:, schools: @schools, filter_form: }
  end

  private

  def filter_form
    @filter_form ||= Organisations::FilterForm.new(filter_params)
  end

  def search_location
    @search_location ||= params[:search_location] || params.dig(:filters, :search_location)
  end

  def academic_year
    @academic_year ||= (AcademicYear.find_by(id: filter_params[:academic_year_id]) || AcademicYear.current)&.decorate
  end

  def location_coordinates
    return if search_location.blank?

    @location_coordinates ||= Geocoder::Search.call(search_location).coordinates
  end

  def filter_params
    params.fetch(:filters, {}).permit(
      :search_location,
      :search_distance,
      :search_by_name,
      :academic_year_id,
      schools_to_show: [],
      phases: [],
      subject_ids: [],
      )
  end

  def query_params
    {
      filters: filter_form.query_params,
      location_coordinates: location_coordinates
    }
  end

  def calculate_travel_time
    return if search_location.blank?

    TravelTime.call(
      origin_address: search_location,
      destinations: @schools.uniq,
    )
  end

  def store_filter_params
    session["find_filter_params"] = { filters: filter_params, page: params[:page] }
  end
end
