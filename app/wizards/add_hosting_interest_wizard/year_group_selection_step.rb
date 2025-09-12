class AddHostingInterestWizard::YearGroupSelectionStep < BaseStep
  include UnknownOptionable

  delegate :academic_year, to: :wizard

  attribute :year_groups, default: []

  validates :year_groups, presence: true

  def year_groups_for_selection
    @year_groups_for_selection ||= year_group_options.map do |value|
      OpenStruct.new(
        value:,
        name: I18n.t("#{locale_path}.year_groups.#{value}"),
        description: I18n.t("#{locale_path}.year_groups.#{value}_description"),
      )
    end
  end

  def year_groups=(value)
    super normalised_year_groups(value)
  end

  private

  def year_group_options
    @year_group_options ||= [
      "nursery",
      "reception",
      "year_1",
      "year_2",
      "year_3",
      "year_4",
      "year_5",
      "year_6",
      "mixed_year_groups"
    ]
  end

  def normalised_year_groups(selected_year_groups)
    return [] if selected_year_groups.blank?

    selected_year_groups.reject(&:blank?)
  end

  def locale_path
    ".wizards.add_hosting_interest_wizard.year_group_selection_step"
  end
end
