require "csv"

  module Importers
    class SchoolUsersImporter < ApplicationService
      attr_reader :csv_path

      def initialize(csv_path)
        @csv_path = csv_path
      end

      def call
        @user_records = Hash.new { |h, k| h[k] = [] }

        CSV.foreach(csv_path, headers: true) do |user|
          @user_records[user["urn"]] << {
            first_name: user["first_name"],
            last_name: user["last_name"],
            email_address: user["email_address"]
          }
        end

        process_user_records

        Rails.logger.info("#{successful_count} of #{total_count} users have been imported successfully.")
      end

      private

      attr_reader :user_records, :successful_count

      def process_user_records
        @successful_count = 0

        user_records.each do |urn, users|
          process_school_users(urn, users)
        end
      end

      def process_school_users(urn, users)
        school = ::School.find_by(urn:)

        if school.present?
          process_users(users, school)
        else
          Rails.logger.error("Failed to import users for school with URN: #{urn}. School not found.")
        end
      end

      def process_users(users, school)
        users.each do |user|
          process_user(user, school)
        end
      end

      def process_user(user, school)
        user_instance = User.find_or_initialize_by(email_address: user[:email_address]) do |new_user|
          new_user.first_name = user[:first_name]
          new_user.last_name = user[:last_name]
        end

        new_user_association = false

        unless user_instance.organisations.exists?(school.id)
          new_user_association = true
          user_instance.organisations << school
        end

        if user_instance.save
          Users::Invite.call(user: user_instance, organisation: school) if new_user_association
          @successful_count += 1
        else
          Rails.logger.error("Failed to import user for #{school.name}: #{user_instance.errors.full_messages.to_sentence}")
        end
      end

      def total_count
        @total_count ||= user_records.values.sum(&:length)
      end
    end
  end
