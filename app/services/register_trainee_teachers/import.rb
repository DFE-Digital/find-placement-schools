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
      ApplicationRecord.transaction do
        csv_data.each do |row|
          PreviousPlacement.find_or_create_by!(
            school_id: row[:school_id],
            academic_year_id: row[:academic_year_id],
            placement_subject_id: row[:subject_id],
          ).tap do |previous_placement|
            previous_placement.number_of_placements = row[:number_of_placements].to_i
            previous_placement.save!
          end
        end
      end
    end
  end
end
