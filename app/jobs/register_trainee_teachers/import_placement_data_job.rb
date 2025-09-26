module RegisterTraineeTeachers
  class ImportPlacementDataJob < ApplicationJob
    queue_as :default

    def perform(csv_data:)
      RegisterTraineeTeachers::Import.call(csv_data:)
    end
  end
end
