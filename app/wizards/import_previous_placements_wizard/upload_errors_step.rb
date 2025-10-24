class ImportPreviousPlacementsWizard::UploadErrorsStep < BaseStep
  delegate :missing_academic_year_rows,
           :invalid_identifier_rows,
           :missing_subject_name_rows,
           :invalid_subject_code_rows,
           :invalid_number_of_placements_rows,
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
    missing_academic_year_rows +
      invalid_identifier_rows +
      missing_subject_name_rows +
      invalid_subject_code_rows +
      invalid_number_of_placements_rows
  end

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end
