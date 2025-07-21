# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
return unless Rails.env.development? || HostingEnvironment.env.review?

def create_user_membership(organisation_name:, user_first_name:)
  organisation = Organisation.find_by!(name: organisation_name)
  user = User.find_by!(first_name: user_first_name)
  UserMembership.find_or_create_by!(organisation:, user:)
end

org_data =[
  {
    "name": "Greenwood Primary School",
    "code": "11111",
    "type": School,
    "urn": "100001",
    "ukprn": "20000001",
    "email_address": "contact@greenwoodprimary.example.org"
  },
  {
    "name": "Riverside College",
    "code": "11112",
    "type": Provider,
    "urn": "100002",
    "ukprn": "20000002",
    "email_address": "info@riversidecollege.example.org"
  },
  {
    "name": "Hilltop Academy",
    "code": "11113",
    "type": School,
    "urn": "100003",
    "ukprn": "20000003",
    "email_address": "office@hilltopacademy.example.org"
  },
  {
    "name": "Northbridge Training",
    "code": "11114",
    "type": Provider,
    "urn": "100004",
    "ukprn": "20000004",
    "email_address": "enquiries@northbridgetraining.example.org"
  },
  {
    "name": "Sunnydale High School",
    "code": "11115",
    "type": School,
    "urn": "100005",
    "ukprn": "20000005",
    "email_address": "admin@sunnydalehigh.example.org"
  }
]

PERSONAS.each do |persona_attributes|
  User.find_or_create_by!(**persona_attributes)
end

org_data.each do |org_attributes|
  Organisation.find_or_create_by!(**org_attributes)
end

create_user_membership(organisation_name: "Greenwood Primary School", user_first_name: "Anne")
create_user_membership(organisation_name: "Northbridge Training", user_first_name: "Mary")
create_user_membership(organisation_name: "Sunnydale High School", user_first_name: "Patricia")
create_user_membership(organisation_name: "Riverside College", user_first_name: "Patricia")
