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

def create_user_membership(organisation:, user_first_name:)
  user = User.find_by!(first_name: user_first_name)
  UserMembership.find_or_create_by!(organisation:, user:)
end

PERSONAS.each do |persona_attributes|
  User.find_or_create_by!(**persona_attributes)
end

GIAS::SyncAllSchoolsJob.perform_now unless School.any?

Provider.find_or_create_by!(code: "2AS") do |provider|
  provider.name = "Oxford University"
  provider.ukprn = 20000002
  provider.email_address = "oxford@university.ac.uk"
end

create_user_membership(organisation: School.first, user_first_name: "Anne")
create_user_membership(organisation: School.second, user_first_name: "Mary")
create_user_membership(organisation: School.third, user_first_name: "Mary")
create_user_membership(organisation: Provider.first, user_first_name: "Patricia")

# Create subjects
PublishTeacherTraining::Subject::Import.call

previous_placement_school = School.all.sample
PlacementSubject.last(3).each do |placement_subject|
  PreviousPlacement.create!(
    placement_subject: placement_subject,
    school: previous_placement_school,
    academic_year: AcademicYear.for_date(Date.today - 1.year),
  )
end
