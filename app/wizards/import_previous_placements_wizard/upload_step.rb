class ImportPreviousPlacementsWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :file_name
  attribute :missing_academic_year_rows, default: []
  attribute :invalid_school_urn_rows, default: []
  attribute :invalid_subject_code_rows, default: []

  REQUIRED_HEADERS = %w[academic_year_start_date school_urn subject_code].freeze

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }
  validate :validate_csv_headers, if: -> { csv_content.present? }

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
  end

  def required_headers_to_sentence
    REQUIRED_HEADERS.map { |header| "'#{header}'" }.to_sentence
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    assign_csv_content
    self.file_name = csv_upload.original_filename

    self.csv_upload = nil
  end

  def validate_csv_file
    errors.add(:csv_upload, :invalid) unless csv_format
  end

  def validate_csv_headers
    csv_headers = csv.headers
    missing_columns = REQUIRED_HEADERS - csv_headers
    return if missing_columns.empty?

    errors.add(:csv_upload,
               :invalid_headers,
               missing_columns: missing_columns.map { |string|
                 "‘#{string}’"
               }.to_sentence)
    errors.add(:csv_upload,
               :uploaded_headers,
               uploaded_headers: csv_headers.map { |string|
                 "‘#{string}’"
               }.to_sentence)
  end

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes

    csv.each_with_index do |row, i|
      next if row["school_urn"].blank?

      validate_academic_year(row, i)
      validate_school(row, i)
      validate_subject_code(row, i)
    end

    missing_academic_year_rows.blank? &&
      invalid_school_urn_rows.blank? &&
      invalid_subject_code_rows.blank?
  end

  def csv
    @csv ||= CSV.parse(read_csv, headers: true, skip_blanks: true)
  end

  private

  def csv_format
    csv_upload.content_type == "text/csv"
  end

  def assign_csv_content
    self.csv_content = read_csv
  end

  def read_csv
    @read_csv ||= csv_content || csv_upload.read
  end

  def reset_input_attributes
    self.missing_academic_year_rows = []
    self.invalid_school_urn_rows = []
    self.invalid_subject_code_rows = []
  end

  def validate_academic_year(row, row_number)
    return if row["academic_year_start_date"].present?

    missing_academic_year_rows << row_number
  end

  def validate_school(row, row_number)
    return unless row["school_urn"].blank? || School.find_by(urn: row["school_urn"].strip).blank?

    invalid_school_urn_rows << row_number
  end

  def validate_subject_code(row, row_number)
    return unless row["subject_code"].blank? ||
      PlacementSubject.find_by(code: row["subject_code"].strip).blank?

    invalid_subject_code_rows << row_number
  end
end
