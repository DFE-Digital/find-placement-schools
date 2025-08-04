class AddHostingInterestWizard::ConfirmStep < AddHostingInterestWizard::CheckYourAnswersStep
  delegate :note, to: :note_to_providers_step

  private

  def note_to_providers_step
    wizard.steps.fetch(:note_to_providers)
  end
end
