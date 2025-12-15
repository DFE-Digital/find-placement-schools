class OnboardUsersWizard < BaseWizard
  def define_steps
    add_step(UserTypeStep)

    if user_type_provider?
      add_step(ProviderUploadStep)
    else
      add_step(SchoolUploadStep)
    end

    if csv_inputs_valid?
      add_step(ConfirmationStep)
    else
      add_step(UploadErrorsStep)
    end
  end

  def upload_users
    raise "Invalid wizard state" unless valid? && csv_inputs_valid?

    return if user_details.blank?

    Users::CreateCollectionJob.perform_later(user_details:)
  end


  def upload_step
    @upload_step ||= steps[user_type_provider? ? :provider_upload : :school_upload]
  end

  private

  def user_details
    @user_details ||= begin
      details = []
      csv_rows.each do |row|
        identifier = user_type_provider? ? row["code"] : row["urn"]
        next if identifier.blank?

        organisation = find_organisation(identifier)

        # Temp add next calls to make the CSV upload work
        next if organisation.blank?
        next if row["email_address"].blank? || URI::MailTo::EMAIL_REGEXP.match(row["email_address"]).nil?

        details << {
          organisation_id: organisation.id,
          first_name: row["first_name"],
          last_name: row["last_name"],
          email_address: row["email_address"]
        }
      end

      details
    end
  end

  def csv_inputs_valid?
    @csv_inputs_valid ||= upload_step.csv_inputs_valid?
  end

  def csv_rows
    upload_step.csv.reject do |row|
      row["email_address"].blank? || (user_type_provider? ? row["code"].blank? : row["urn"].blank?)
    end
  end

  def find_organisation(identifier)
    if user_type_provider?
      Provider.find_by(code: identifier)
    else
      School.find_by(urn: identifier)
    end
  end

  def user_type_provider?
    @user_type_provider ||= steps.fetch(:user_type).user_type == "provider"
  end
end
