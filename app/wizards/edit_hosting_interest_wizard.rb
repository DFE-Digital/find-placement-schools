class EditHostingInterestWizard < AddHostingInterestWizard
  attr_reader :placement_preference

  def initialize(placement_preference:, current_user:, school:, params:, state:, current_step: nil)
    @placement_preference = placement_preference
    academic_year = placement_preference.academic_year

    super(current_user:, school:, academic_year:, params:, state:, current_step:)
  end

  def setup_state
    placement_details.each_key do |step_name|
      state[step_name] = placement_details.dig(step_name.to_s)
    end
  end

  def academic_year
    placement_preference.academic_year.decorate
  end

  private

  def edit_mode?
    true
  end

  def placement_details
    @placement_details ||= placement_preference.placement_details
  end
end
