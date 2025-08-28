class SchoolMailer < ApplicationMailer
  def placement_request_notification(school)
    @school = school
    @placements_requests = school.placement_requests.not_sent
    @placement_details = school.placement_preference_for(academic_year: AcademicYear.next).placement_details
    email_address = @placement_details.dig("school_contact", "email_address")

    notify_email to: email_address, subject: t(".help_hosting_itt_placements")
  end
end
