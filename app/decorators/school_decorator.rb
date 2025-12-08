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

  def previous_academic_year_hosted_placements(academic_year)
    previous_academic_year = academic_year.previous
    return unless previous_academic_year.present?
    return unless previous_placements.where(academic_year: previous_academic_year).exists?

    hosted_placements_for_years([ previous_academic_year ])
  end

  def previous_academic_years_hosted_placements(academic_year)
    years = []
    current = academic_year.previous

    while current.present? && years.size < 2
      break if years.include?(current)
      years << current
      current = current.previous
    end

    hosted_placements_for_years(years)
  end

  def website_link
    return I18n.t("helpers.text_helper.unknown") if website.blank?

    url = website.to_s.strip
    url = "https://#{url}" unless url.blank? || url =~ /\Ahttps?:\/\//i
    h.govuk_link_to(url, url, new_tab: true, rel: "noopener noreferrer")
  end

  private

  def hosted_placements_for_years(years)
    previous_hosted_placements = {}
    years.each do |year|
      placements = previous_placements.where(academic_year: year)
      next unless placements.exists?

      subject_names = PlacementSubject.where(
        id: placements.select(:placement_subject_id)
      ).order_by_name.pluck(:name)
      previous_hosted_placements[year.name] = subject_names.to_sentence
    end

    previous_hosted_placements
  end
end
