class GIAS::CSVDownloader < ApplicationService
  def call
    yesterday = Time.zone.yesterday.strftime("%Y%m%d")
    gias_filename = "edubasealldata#{yesterday}.csv"

    Rails.logger.info "Downloading the new gias file for #{Time.zone.yesterday}"
    begin
      file = Down.download("#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}")

      # GIAS CSVs are published with ISO-8859-1 character encoding.
      # This needs to be set manually because the GIAS server doesn't specify the charset.
      # Without this, some characters will appear weirdly when the file is read.
      file.set_encoding("ISO-8859-1")
    rescue Down::Error => e
      Rails.logger.error "Failed to download the GIAS file: #{e.message}"
      raise
    end

    file
  end
end
