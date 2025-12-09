class ImportPreviousPlacementsWizard < BaseWizard
  def initialize(params:, state:, current_step: nil)
    super(state:, params:, current_step:)
  end

  def define_steps
    add_step(UploadStep)
    if csv_inputs_valid?
      add_step(ConfirmationStep)
    else
      add_step(UploadErrorsStep)
    end
  end

  def import_previous_placements
    raise "Invalid wizard state" unless valid? && csv_inputs_valid?

    RegisterTraineeTeachers::ImportPlacementDataJob.perform_later(
      csv_data: previous_placements_data,
    )
  end

  private

  def csv_inputs_valid?
    @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
  end

  def csv_rows
    steps.fetch(:upload).csv.reject do |row|
      row["school_urn"].blank?
    end
  end

  def previous_placements_data
    return [] if steps[:upload].blank?

    csv_rows.map do |row|
      {
        school_id: School.find_by!(urn: row["school_urn"]).id,
        academic_year_id: AcademicYear.for_date(Date.parse(row["academic_year_start_date"])).id,
        subject_id: PlacementSubject.find_by(code: row["subject_code"]).id,
        number_of_placements: row["number_of_placements"].to_i
      }
    end
  end
end
