class DevelopmentSeedData < ApplicationService
  PLACEMENT_PROFILES = [
    {
      appetite: "actively_looking",
      phases: %w[primary],
      year_groups: %w[reception year_1 year_2]
    },
    {
      appetite: "actively_looking",
      phases: %w[secondary],
      subject_group_index: 0
    },
    {
      appetite: "actively_looking",
      phases: %w[send],
      key_stages: %w[key_stage_1 key_stage_2]
    },
    {
      appetite: "actively_looking",
      phases: %w[primary secondary],
      year_groups: %w[year_3 year_4 year_5],
      subject_group_index: 1
    },
    {
      appetite: "actively_looking",
      phases: %w[secondary send],
      key_stages: %w[key_stage_3 key_stage_4],
      subject_group_index: 2
    },
    {
      appetite: "interested",
      phases: %w[primary],
      year_groups: %w[year_1 year_2 year_3]
    },
    {
      appetite: "interested",
      phases: %w[primary secondary],
      year_groups: %w[year_4 year_5],
      subject_group_index: 3
    },
    {
      appetite: "interested",
      phases: %w[secondary],
      subject_group_index: 4
    },
    {
      appetite: "interested",
      phases: %w[send],
      key_stages: %w[key_stage_2 key_stage_5]
    },
    {
      appetite: "not_open",
      phases: %w[primary secondary send],
      year_groups: %w[year_6],
      key_stages: %w[key_stage_4],
      subject_group_index: 5
    }
  ].freeze
  CONTACT_NAMES = [
    [ "Alex", "Taylor" ],
    [ "Jordan", "Patel" ],
    [ "Sam", "Morgan" ],
    [ "Riley", "Ahmed" ],
    [ "Casey", "Bennett" ],
    [ "Jamie", "Nguyen" ]
  ].freeze
  CURRENT_YEAR_PLACEMENT_COUNT = 36
  NEXT_YEAR_PLACEMENT_COUNT = 30
  FOLLOWING_YEAR_PLACEMENT_COUNT = 24

  def call
    return unless Rails.env.development? || HostingEnvironment.env.az_development?

    seed_personas
    seed_schools
    seed_provider
    seed_user_memberships
    seed_subjects
    seed_development_placement_preferences
    seed_previous_placements
  end

  private

  def seed_personas
    PERSONAS.each do |persona_attributes|
      User.find_or_create_by!(**persona_attributes)
    end
  end

  def seed_schools
    GIAS::SyncAllSchoolsJob.perform_now unless School.any?
  end

  def seed_provider
    Provider.find_or_create_by!(code: "2AS") do |provider|
      provider.name = "Oxford University"
      provider.ukprn = 20000002
      provider.email_address = "oxford@university.ac.uk"
    end
  end

  def seed_user_memberships
    create_user_membership(organisation: School.first, user_first_name: "Anne")
    create_user_membership(organisation: School.second, user_first_name: "Mary")
    create_user_membership(organisation: School.third, user_first_name: "Mary")
    create_user_membership(organisation: Provider.first, user_first_name: "Patricia")
  end

  def seed_subjects
    PublishTeacherTraining::Subject::Import.call
  end

  def create_user_membership(organisation:, user_first_name:)
    user = User.find_by!(first_name: user_first_name)
    UserMembership.find_or_create_by!(organisation:, user:)
  end

  def seed_development_placement_preferences
    academic_year_plan.each_with_index do |(academic_year, school_count), year_index|
      schools_for(school_count:, year_index:).each_with_index do |school, index|
        profile = PLACEMENT_PROFILES.fetch(index % PLACEMENT_PROFILES.length)
        subject_group = subject_group_for(profile)

        upsert_placement_preference(
          school:,
          academic_year:,
          created_by: provider_user,
          appetite: profile[:appetite],
          placement_details: build_placement_details(
            appetite: profile[:appetite],
            phases: profile[:phases],
            school_contact: contact_details(index),
            year_groups: profile.fetch(:year_groups, []),
            key_stages: profile.fetch(:key_stages, []),
            subject_ids: subject_group.map(&:first)
          )
        )
      end
    end
  end

  def academic_year_plan
    {
      AcademicYear.current => CURRENT_YEAR_PLACEMENT_COUNT,
      AcademicYear.next => NEXT_YEAR_PLACEMENT_COUNT,
      AcademicYear.for_date(Date.current + 2.years) => FOLLOWING_YEAR_PLACEMENT_COUNT
    }
  end

  def schools_for(school_count:, year_index:)
    school_offset = academic_year_plan.values.take(year_index).sum
    School.order(:urn).limit(total_placement_preference_school_count).offset(school_offset).first(school_count)
  end

  def total_placement_preference_school_count
    academic_year_plan.values.sum
  end

  def secondary_subject_groups
    @secondary_subject_groups ||= PlacementSubject.secondary.order(:name).limit(24).pluck(:id, :name).each_slice(3).to_a
  end

  def subject_group_for(profile)
    return [] unless secondary_subject_groups.any? && profile[:subject_group_index].present?

    secondary_subject_groups.fetch(profile[:subject_group_index] % secondary_subject_groups.length)
  end

  def provider_user
    @provider_user ||= User.find_by!(first_name: "Patricia")
  end

  def build_placement_details(appetite:, phases:, school_contact:, year_groups: [], key_stages: [], subject_ids: [])
    {
      "appetite" => {
        "appetite" => appetite
      },
      "phase" => {
        "phases" => phases
      },
      "school_contact" => school_contact
    }.tap do |placement_details|
      placement_details["year_group_selection"] = {
        "year_groups" => year_groups
      } if year_groups.any?

      placement_details["key_stage_selection"] = {
        "key_stages" => key_stages
      } if key_stages.any?

      placement_details["secondary_subject_selection"] = {
        "subject_ids" => subject_ids
      } if subject_ids.any?
    end
  end

  def upsert_placement_preference(school:, academic_year:, created_by:, appetite:, placement_details:)
    placement_preference = school.placement_preference_for(academic_year:) || school.placement_preferences.build(
      academic_year:,
      created_by:
    )

    placement_preference.update!(
      appetite:,
      created_by:,
      placement_details:
    )
  end

  def contact_details(index)
    first_name, last_name = CONTACT_NAMES.fetch(index % CONTACT_NAMES.size)

    {
      "first_name" => first_name,
      "last_name" => last_name,
      "email_address" => "#{first_name.downcase}.#{last_name.downcase}@example.org"
    }
  end

  def seed_previous_placements
    return if previous_placement_subject_names.empty?

    previous_placement_schools.each_with_index do |school, index|
      rotated_subject_names = previous_placement_subject_names.rotate(index)

      previous_academic_years.each_with_index do |academic_year, year_index|
        rotated_subject_names.first(year_index + 2).each do |subject_name|
          PreviousPlacement.find_or_create_by!(
            school:,
            subject_name:,
            academic_year:
          )
        end
      end
    end
  end

  def previous_placement_subject_names
    @previous_placement_subject_names ||= PlacementSubject.secondary.order(:name).limit(12).pluck(:name)
  end

  def previous_academic_years
    [ AcademicYear.for_date(Date.current - 2.years), AcademicYear.previous ]
  end

  def previous_placement_schools
    @previous_placement_schools ||= begin
      School.order(:urn).limit(24).to_a +
        School.order(:urn).offset(total_placement_preference_school_count).limit(12).to_a
    end.uniq
  end
end
