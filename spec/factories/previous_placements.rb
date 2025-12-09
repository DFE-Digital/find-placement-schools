FactoryBot.define do
  factory :previous_placement do
    subject_name { "Mathematics" }

    association :academic_year, :current
    association :school, factory: :school
  end
end
