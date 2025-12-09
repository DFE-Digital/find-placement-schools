module PublishTeacherTraining
  module Provider
    class Importer < ApplicationService
      def call
        @invalid_records = []
        @records = []
        @address_records = []

        fetch_providers

        if @invalid_records.any?
          Rails.logger.info "Invalid Providers - #{@invalid_records.inspect}"
        end

        Rails.logger.silence do
          ::Provider.upsert_all(@records, unique_by: :index_organisations_on_type_and_code)
          associate_providers_to_addresses(@address_records)
        end

        Rails.logger.info "Done!"
      end

      private

      def invalid?(provider_attributes)
        provider_attributes["name"].blank? || provider_attributes["code"].blank?
      end

      def fetch_providers(link = nil)
        providers = ::PublishTeacherTraining::Provider::API.call(link:)
        providers.fetch("data").each do |provider_details|
          provider_attributes = provider_details["attributes"]
          @invalid_records << "Provider with code #{provider_attributes["code"]} is invalid" if invalid?(provider_attributes)
          next if invalid?(provider_attributes)

          @records << {
            code: provider_attributes["code"],
            name: provider_attributes["name"],
            ukprn: provider_attributes["ukprn"],
            urn: provider_attributes["urn"],
            telephone: provider_attributes["telephone"],
            email_address: provider_attributes["email"],
            website: provider_attributes["website"],
            latitude: provider_attributes["latitude"],
            longitude: provider_attributes["longitude"]
          }

          @address_records << {
            code: provider_attributes["code"],
            address_1: provider_attributes["street_address_1"],
            address_2: provider_attributes["street_address_2"],
            address_3: provider_attributes["street_address_3"],
            city: provider_attributes["city"],
            postcode: provider_attributes["postcode"]
          }
        end

        if providers.dig("links", "next").present?
          fetch_providers(providers.dig("links", "next"))
        end
      end

      def associate_providers_to_addresses(address_records)
        Rails.logger.info "Associating addresses to providers..."

        # Preload all providers into a hash for efficient lookup
        providers_by_codes = ::Provider.all.index_by(&:code)

        address_data = address_records.map do |address|
          provider = providers_by_codes[address[:code]]
          raise ActiveRecord::RecordNotFound, "Provider with code #{address[:code]} not found" unless provider

          {
            organisation_id: provider.id,
            address_1: address[:address_1],
            address_2: address[:address_2],
            address_3: address[:address_3],
            town: address[:town],
            postcode: address[:postcode],
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        OrganisationAddress.upsert_all(address_data, unique_by: :organisation_id)
      end
    end
  end
end
