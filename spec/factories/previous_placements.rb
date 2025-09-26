FactoryBot.define do
  factory :previous_placement do
    association :academic_year, :next
    association :school, factory: :school
    association :placement_subject
  end
end
