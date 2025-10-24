class AddHostingInterestWizard < BaseWizard
  include PlacementPreferenceCreatable

  attr_reader :school, :current_user

  delegate :school_contact, to: :school

  UNKNOWN_OPTION = "unknown".freeze

  def initialize(current_user:, school:, params:, state:, current_step: nil)
    @school = school
    @current_user = current_user
    super(state:, params:, current_step:)
    return unless steps[:school_contact].present?

    save_contact_details if steps.fetch(:school_contact).email_address.present?
  end

  def define_steps
    # Define the wizard steps here
    add_step(AppetiteStep)
    case appetite
    when "actively_looking"
      actively_looking_steps
    when "not_open"
      not_open_steps
    when "interested"
      interested_steps
    end
  end

  def save_placement_preference
    raise "Invalid wizard state" unless valid?

    save_placement_details
    placement_preference
  end

  def selected_secondary_subjects
    return [ UNKNOWN_OPTION ] if selected_secondary_subject_ids.include?(UNKNOWN_OPTION)

    super
  end

  def academic_year
    @academic_year ||= AcademicYear.next.decorate
  end

  private

  def save_contact_details
    details_changed = false

    ApplicationRecord.transaction do
      if placement_preference.appetite != appetite
        placement_preference.appetite = appetite
        details_changed = true
      end

      if placement_preference.placement_details.dig("school_contact") != steps.fetch(:school_contact).attributes
        placement_preference.placement_details[:appetite] = steps.fetch(:appetite).attributes
        placement_preference.placement_details[:school_contact] = steps.fetch(:school_contact).attributes
        details_changed = true
      end

      placement_preference.save! if details_changed
    end
  end

  def save_placement_details
    ApplicationRecord.transaction do
      placement_preference.appetite = appetite
      placement_preference.placement_details = state.select do |step_name, attributes|
        steps.keys.include?(step_name.to_sym) && attributes.present?
      end

      placement_preference.save!
    end
  end

  def actively_looking_steps
    add_step(SchoolContactStep)
    add_placement_creation_steps(with_check_your_answers: false)
    add_step(NoteToProvidersStep)
    add_step(CheckYourAnswersStep)
  end

  def interested_steps
    add_step(SchoolContactStep)
    add_step(Interested::PhaseStep)
    if primary_phase?
      year_group_steps
    end

    if secondary_phase?
      secondary_subject_steps
    end

    if send_specific?
      send_steps
    end

    add_step(Interested::NoteToProvidersStep)
    add_step(ConfirmStep)
  end

  def not_open_steps
    add_step(NotOpen::SchoolContactStep)
    add_step(ReasonNotHostingStep)
    add_step(AreYouSureStep)
  end

  def year_group_steps
    if appetite_interested?
      add_step(Interested::YearGroupSelectionStep)
    else
      super
    end
  end

  def secondary_subject_steps
    if appetite_interested?
      add_step(Interested::SecondarySubjectSelectionStep)
      child_subject_steps(step_prefix: Interested)
    else
      super
    end
  end

  def send_steps
    if appetite_interested?
      add_step(Interested::KeyStageSelectionStep)
    else
      super
    end
  end

  def child_subject_steps(step_prefix: AddHostingInterestWizard)
    return if selected_secondary_subjects == [ UNKNOWN_OPTION ]

    super(step_prefix:)
  end

  def appetite
    @appetite ||= steps.fetch(:appetite).appetite
  end

  def placement_preference
    @placement_preference ||= begin
      upcoming_interest = school.placement_preferences.for_academic_year(academic_year).last
      upcoming_interest.presence || school.placement_preferences.build(
        academic_year: academic_year,
        created_by: current_user,
        placement_details: {},
      )
    end
  end

  def appetite_interested?
    @appetite_interested ||= appetite == "interested"
  end
end
