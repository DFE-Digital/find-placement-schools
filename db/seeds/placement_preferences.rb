# Sample placement preferences so accessibility testers can browse schools'
# hosting interest as a provider (Patricia) and add their own as a school (Anne).
#
# Anne's school (School.first) is deliberately left without a preference for the
# upcoming academic year so the "add hosting interest" journey can be walked through.
admin = User.find_by!(first_name: "Colin")
academic_years = [ AcademicYear.current, AcademicYear.next ]
secondary_subjects = PlacementSubject.parent_subjects.secondary.order(:name).limit(3).pluck(:id)

example_schools = School.order(:id).offset(3).limit(6).to_a

example_preferences = [
  {
    appetite: "actively_looking",
    placement_details: {
      appetite: { appetite: "actively_looking" },
      phase: { phases: %w[primary secondary] },
      year_group_selection: { year_groups: %w[reception year_1 year_2] },
      secondary_subject_selection: { subject_ids: secondary_subjects },
      note_to_providers: { note: "We can host two trainees and have experienced mentors." }
    }
  },
  {
    appetite: "actively_looking",
    placement_details: {
      appetite: { appetite: "actively_looking" },
      phase: { phases: %w[secondary] },
      secondary_subject_selection: { subject_ids: secondary_subjects.first(2) }
    }
  },
  {
    appetite: "interested",
    placement_details: {
      appetite: { appetite: "interested" },
      phase: { phases: %w[primary] },
      year_group_selection: { year_groups: %w[year_3 year_4 year_5 year_6] },
      note_to_providers: { note: "Interested, but need to confirm mentor availability." }
    }
  },
  {
    appetite: "interested",
    placement_details: {
      appetite: { appetite: "interested" },
      phase: { phases: %w[send] },
      key_stage_selection: { key_stages: %w[key_stage_3 key_stage_4] }
    }
  },
  {
    appetite: "not_open",
    placement_details: {
      appetite: { appetite: "not_open" },
      reason_not_hosting: { reasons_not_hosting: [ "Low capacity to support trainees" ] }
    }
  },
  {
    appetite: "not_open",
    placement_details: {
      appetite: { appetite: "not_open" },
      reason_not_hosting: { reasons_not_hosting: [ "Not enough trained mentors" ] }
    }
  }
]

example_schools.zip(example_preferences).each do |school, attributes|
  next if school.blank?

  contact = {
    first_name: "Example",
    last_name: "Contact",
    email_address: "placements+#{school.urn}@example.com"
  }

  academic_years.each do |academic_year|
    PlacementPreference.find_or_create_by!(organisation: school, academic_year:) do |preference|
      preference.created_by = admin
      preference.appetite = attributes[:appetite]
      preference.placement_details = attributes[:placement_details].merge(school_contact: contact)
    end
  end
end
