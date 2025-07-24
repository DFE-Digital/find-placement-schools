FactoryBot.define do
  factory :user_membership do
    association :user, factory: :user
    association :organisation, factory: :school
  end
end
