FactoryBot.define do
  factory :placement_request do
    association :provider, factory: :provider
    association :school, factory: :school
    association :requested_by, factory: :user

    trait :sent do
      sent_at { Time.current }
    end
  end
end
