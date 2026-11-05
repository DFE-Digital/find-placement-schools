FactoryBot.define do
  factory :placement_preference_reminder do
    association :user
    association :organisation, factory: :school
    academic_year { AcademicYear.next }
  end
end
