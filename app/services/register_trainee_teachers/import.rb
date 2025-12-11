module RegisterTraineeTeachers
  class Import < ApplicationService
    attr_reader :csv_data

    def initialize(csv_data:)
      @csv_data = csv_data
    end

    def call
      create_previous_placements
    end

    private

    def create_previous_placements
      csv_data.each do |row|
        next unless row.present? && all_values_present?(row)

        PreviousPlacement.find_or_create_by(
          school_id: row[:school_id],
          academic_year_id: row[:academic_year_id],
          subject_name: row[:subject_name],
        )
      end
    end

    def all_values_present?(row)
      row[:school_id].present? &&
      row[:academic_year_id].present? &&
      row[:subject_name].present?
    end
  end
end
