class GIAS::SyncAllSchoolsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Downloading GIAS CSV file..."
    gias_csv = GIAS::CSVDownloader.call

    Rails.logger.info "Transforming GIAS CSV file..."
    transformed_csv = GIAS::CSVTransformer.call(gias_csv)

    Rails.logger.info "Importing GIAS data"
    GIAS::CSVImporter.call(transformed_csv.path)

    gias_csv.unlink
    transformed_csv.unlink
    Rails.logger.info "Done"
  end
end
