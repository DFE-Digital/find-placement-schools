class InterestTagComponent < ApplicationComponent
  INTEREST_COLOURS = {
    "actively_looking" => "green",
    "interested" => "yellow",
    "not_open" => "red",
    "not_participating" => "grey",
    "previously_offered" => "blue"
  }.freeze

  INTEREST_TEXT = {
    "actively_looking" => I18n.t("components.interest_tag_component.actively_looking"),
    "interested" => I18n.t("components.interest_tag_component.interested"),
    "not_open" => I18n.t("components.interest_tag_component.not_open"),
    "not_participating" => I18n.t("components.interest_tag_component.not_participating"),
    "previously_offered" => I18n.t("components.interest_tag_component.previously_offered")
  }.freeze

  private_constant :INTEREST_COLOURS, :INTEREST_TEXT

  def initialize(school:, academic_year:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @school = school
    @academic_year = academic_year
  end

  def call
    render GovukComponent::TagComponent.new(text: interest_text, colour: interest_colour)
  end

  private

  attr_reader :school, :academic_year

  def interest_colour
    INTEREST_COLOURS[calculated_status]
  end

  def interest_text
    INTEREST_TEXT[calculated_status]
  end

  def calculated_status
    if actively_looking?
      "actively_looking"
    elsif interested?
      "interested"
    elsif not_looking?
      "not_open"
    elsif previously_offered_placements?
      "previously_offered"
    else
      "not_participating"
    end
  end

  def actively_looking?
    placement_preference&.actively_looking?
  end

  def interested?
    placement_preference&.interested?
  end

  def not_looking?
    placement_preference&.not_open?
  end

  def previously_offered_placements?
    prior_academic_years = AcademicYear.where("starts_on < ?", academic_year.starts_on).order(starts_on: :desc).limit(3)
    school.previous_placements.where(academic_year: prior_academic_years).exists?
  end

  def placement_preference
    @placement_preference ||= school.placement_preference_for(academic_year:)
  end
end
