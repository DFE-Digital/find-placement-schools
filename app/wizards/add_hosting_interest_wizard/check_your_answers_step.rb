class AddHostingInterestWizard::CheckYourAnswersStep < BaseStep
  delegate :phases, to: :phase_step
  delegate :appetite, to: :appetite_step
  delegate :year_groups, :selected_secondary_subjects, :key_stages, :step_name_for_child_subjects, to: :wizard
  delegate :first_name, :last_name, :email_address, to: :school_contact_step, prefix: :school_contact
  delegate :note, to: :note_to_providers_step

  def child_subject_names(subject:)
    return [] unless subject.has_child_subjects? && wizard.steps[step_name_for_child_subjects(subject:)].present?

    PlacementSubject.where(id: wizard.steps[step_name_for_child_subjects(subject:)].child_subject_ids).order_by_name.pluck(:name)
  end

  private

  def phase_step
    wizard.steps.fetch(:phase)
  end

  def school_contact_step
    wizard.steps.fetch(:school_contact)
  end

  def appetite_step
    wizard.steps.fetch(:appetite)
  end

  def note_to_providers_step
    wizard.steps.fetch(:note_to_providers)
  end
end
