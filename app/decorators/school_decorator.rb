class SchoolDecorator < ApplicationDecorator
  include ActionView::Helpers::TextHelper

  delegate_all

  def formatted_inspection_date
    return "" if last_inspection_date.blank?

    I18n.l(last_inspection_date, format: :long)
  end

  def age_range
    "#{minimum_age} to #{maximum_age}"
  end

  def percentage_free_school_meals_percentage
    return "Unknown" if percentage_free_school_meals.blank?
    "#{percentage_free_school_meals}%" if percentage_free_school_meals.present?
  end

  def formatted_address(wrapper_tag: "p")
    return if address_string.blank?

    simple_format(address_string, {}, wrapper_tag:)
  end

  def formatted_duration(mode)
    method = case mode
    when "transit"
      "transit_travel_duration"
    when "drive"
      "drive_travel_duration"
    when "walk"
      "walk_travel_duration"
    end

    duration = send(method)
    return "" if duration.blank?

    duration.gsub(/\bmins\b/, "minutes")
  end

  def previously_hosted_placements
    @previously_hosted_placements ||= begin
      previous_hosted_placements ||= {}
      academic_years = AcademicYear
         .where("starts_on < ?", Date.current)
         .order("starts_on DESC")
         .limit(3)
      return unless previous_placements.where(academic_year: academic_years).exists?

      academic_years.map do |academic_year|
        subject_names = PlacementSubject.where(
          id: previous_placements.where(academic_year: academic_year).select(:placement_subject_id)
        ).order(:name).pluck(:name)
        next if subject_names.blank?

        previous_hosted_placements[academic_year.name] = subject_names.to_sentence
      end

      previous_hosted_placements
    end
  end
end
