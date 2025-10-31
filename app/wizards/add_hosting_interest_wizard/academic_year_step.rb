class AddHostingInterestWizard::AcademicYearStep < BaseStep
  attribute :academic_year_id

  validates :academic_year_id, presence: true

  delegate :school, to: :wizard

  def academic_year_options
    options = Struct.new(:value, :name)
    academic_years.map do |academic_year|
      options.new(value: academic_year.id, name: academic_year.name)
    end
  end

  private

  def academic_years
    @academic_years ||= [].tap do |years|
      years << AcademicYear.current unless school.placement_preferences.exists?(academic_year: AcademicYear.current)
      years << AcademicYear.next
    end
  end

  def locale_path
    ".wizards.add_hosting_interest_wizard.academic_year_step"
  end
end
