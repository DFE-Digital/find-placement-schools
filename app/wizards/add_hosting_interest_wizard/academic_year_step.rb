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

  def recent_preference_exists?
    wizard.placement_preference_exists_for?(AcademicYear.current) || wizard.placement_preference_exists_for?(AcademicYear.next)
  end

  def existing_preference_academic_year
    wizard.placement_preference_exists_for?(AcademicYear.current) ? AcademicYear.current : AcademicYear.next
  end

  def new_academic_year
    wizard.placement_preference_exists_for?(AcademicYear.current) ? AcademicYear.next : AcademicYear.current
  end

  def recent_placement_preference
    wizard.placement_preference_for(existing_preference_academic_year)
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
