class OnboardUsersWizard::UploadErrorsStep < BaseStep
  delegate :invalid_email_address_rows,
           :invalid_identifier_rows,
           :missing_first_name_rows,
           :missing_last_name_rows,
           :file_name,
           :csv,
           to: :upload_step

  def row_indexes_with_errors
    combined_errors.uniq.sort
  end

  def error_count
    combined_errors.count
  end

  private

  def combined_errors
    invalid_identifier_rows +
      invalid_email_address_rows +
      missing_first_name_rows +
      missing_last_name_rows
  end

  def upload_step
    @upload_step ||= wizard.upload_step
  end
end
