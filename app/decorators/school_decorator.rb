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
    academic_years = 5.times.map{ |i| AcademicYear.for_date(Date.today - i.years) }
    return unless previous_placements.where(academic_year: academic_years).exists?

    academic_years.map do |academic_year|
      subject_names = previous_placements.where(academic_year: academic_year)
        .map(&:placement_subject_name)
        .sort
      next if subject_names.blank?

      "#{academic_year.name} - #{subject_names.to_sentence}"
    end
  end
end
