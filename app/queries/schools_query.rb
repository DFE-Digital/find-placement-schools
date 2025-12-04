class SchoolsQuery < ApplicationQuery
  MAX_LOCATION_DISTANCE = 50

  def call
    scope = School.left_outer_joins(:placement_preferences)
    scope = academic_year_condition(scope)
    scope = schools_to_show_condition(scope)
    scope = search_by_name_condition(scope)
    scope = phase_condition(scope)
    scope = subject_condition(scope)
    order_condition(scope)
  end

  private

  def search_by_name_condition(scope)
    return scope if filter_params[:search_by_name].blank?

    search_query = "%#{filter_params[:search_by_name]}%"
    scope.left_outer_joins(:organisation_address)
         .where("organisations.name ILIKE ? OR organisations.urn ILIKE ? OR organisation_addresses.postcode ILIKE ?", search_query, search_query, search_query)
  end

  def phase_condition(scope)
    return scope if filter_params[:phases].blank?

    scope.where(
      "(placement_preferences.placement_details #> '{phase,phases}') ?| array[:options]",
      options: filter_params[:phases],
    )
  end

  def subject_condition(scope)
    return scope if filter_params[:subject_ids].blank?

    scope.where(
      "(placement_preferences.placement_details #> '{secondary_subject_selection,subject_ids}') ?| array[:options]", options: filter_params[:subject_ids])
  end

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end

  def organisation_ids_near_location(location_coordinates)
    Organisation.near(
      location_coordinates,
      max_radius,
      order: :distance,
    ).map(&:id)
  end

  def schools_to_show_condition(scope)
    return scope if filter_params[:schools_to_show].blank?

    ids = []

    if filter_params[:schools_to_show].include?("previously_hosted")
      ids += School.joins(:previous_placements)
                   .where(previous_placements: { academic_year: selected_academic_year.previous })
                   .pluck(:id)
    end

    appetite_values = filter_params[:schools_to_show] - [ "previously_hosted" ]
    if appetite_values.any?
      ids += School.left_outer_joins(:placement_preferences)
                   .where(placement_preferences: { academic_year_id: selected_academic_year, appetite: appetite_values })
                   .pluck(:id)
    end

    ids.uniq!
    return scope if ids.empty?

    scope.where(id: ids)
  end

  def academic_year_condition(scope)
    scope.where("placement_preferences.academic_year_id = :year OR placement_preferences.id IS NULL", year: filter_params[:academic_year_id])
  end

  def order_condition(scope)
    if params[:location_coordinates].present?
      organisation_ids = organisation_ids_near_location(
        params[:location_coordinates],
      )

      sanitised_ids = organisation_ids.map { |id| ActiveRecord::Base.connection.quote(id) }.join(",")
      scope.where(id: organisation_ids)
           .select("organisations.*, array_position(ARRAY[#{sanitised_ids}]::uuid[], organisations.id) AS ordering_index")
           .distinct
           .order(Arel.sql("ordering_index"))
    else
      scope.select(
        "organisations.*, CASE
          WHEN placement_preferences.appetite = 'actively_looking' THEN 1
          WHEN placement_preferences.appetite = 'interested' THEN 2
          WHEN EXISTS (SELECT 1 FROM previous_placements WHERE previous_placements.school_id = organisations.id) THEN 3
          WHEN placement_preferences.appetite = 'not_open' THEN 5
          ELSE 4
        END AS ordering_index"
      )
       .distinct
       .order(Arel.sql("ordering_index"), :name)
    end
  end

  def max_radius
    if filter_params[:search_distance].present?
      [ filter_params[:search_distance].to_i, MAX_LOCATION_DISTANCE ].compact.min
    else
      MAX_LOCATION_DISTANCE
    end
  end

  private

  def send_value
    AddHostingInterestWizard::PhaseStep::SEND
  end

  def selected_academic_year
    AcademicYear.find_by(id: filter_params[:academic_year_id])
  end
end
