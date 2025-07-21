class GIAS::CSVImporter < ApplicationService
  attr_reader :csv_path
  def initialize(csv_path)
    @csv_path = csv_path
  end

  def call
    school_records = []
    address_records = []

    CSV.foreach(csv_path, headers: true) do |school|
      next if school["URN"].blank?

      school_records << {
        urn: school["URN"],
        name: school["EstablishmentName"],
        district_admin_name: school["DistrictAdministrative (name)"],
        district_admin_code: school["DistrictAdministrative (code)"],
        ukprn: school["UKPRN"].presence,
        website: school["SchoolWebsite"].presence,
        telephone: school["TelephoneNum"].presence,
        group: school["EstablishmentTypeGroup (name)"].presence,
        type_of_establishment: school["TypeOfEstablishment (name)"].presence,
        local_authority_name: school["LA (name)"].presence,
        local_authority_code: school["LA (code)"].presence,
        phase: school["PhaseOfEducation (name)"].presence,
        gender: school["Gender (name)"].presence,
        minimum_age: school["StatutoryLowAge"].presence,
        maximum_age: school["StatutoryHighAge"].presence,
        religious_character: school["ReligiousCharacter (name)"].presence,
        admissions_policy: school["AdmissionsPolicy (name)"].presence,
        urban_or_rural: school["UrbanRural (name)"].presence,
        school_capacity: school["SchoolCapacity"].presence,
        total_pupils: school["NumberOfPupils"].presence,
        total_boys: school["NumberOfBoys"].presence,
        total_girls: school["NumberOfGirls"].presence,
        percentage_free_school_meals: school["PercentageFSM"].presence,
        special_classes: school["SpecialClasses (name)"].presence,
        send_provision: school["TypeOfResourcedProvision (name)"].presence,
        rating: school["OfstedRating (name)"].presence,
        last_inspection_date: school["OfstedLastInsp"].presence,
        latitude: school["Latitude"].presence,
        longitude: school["Longitude"].presence
      }

      address_records << {
        school_urn: school["URN"],
        address1: school["Street"].presence,
        address2: school["Locality"].presence,
        address3: school["Address3"].presence,
        town: school["Town"].presence,
        postcode: school["Postcode"].presence
      }
    end

    Rails.logger.silence do
      School.upsert_all(school_records, unique_by: :urn)
      associate_schools_to_addresses(address_records)
    end

    Rails.logger.info "GIAS Data Imported!"

    Rails.logger.silence do
      # Organisations which have not created placement preferences
      inactive_schools_scope = School.where.missing(:placement_preferences)
      # Inactive schools which did not appear in the imported data
      schools_to_remove = inactive_schools_scope.where.not(urn: school_records.pluck(:urn))

      schools_to_remove.delete_all
    end

    Rails.logger.info "Deleted schools which have been closed from the database."
  end

  private

  def associate_schools_to_addresses(address_records)
    Rails.logger.debug "Associating schools to addresses... "

    address_data = address_records.map do |address|
      {
        organisation_id: School.find_by!(urn: address[:school_urn]).id,
        address_1: address[:address1],
        address_2: address[:address2],
        address_3: address[:address3],
        town: address[:town],
        postcode: address[:postcode],
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    OrganisationAddress.upsert_all(address_data, unique_by: :organisation_id)
  end
end
