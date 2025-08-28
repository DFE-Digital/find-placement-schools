FactoryBot.define do
  factory :placement_request do
    association :provider, factory: :provider
    association :school, factory: :school
    association :requested_by, factory: :user
  end
end
