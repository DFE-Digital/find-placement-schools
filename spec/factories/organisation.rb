FactoryBot.define do
  factory :organisation do
    trait :school do
      type { "School" }
      name { "Hogwarts" }
      urn { "123456" }
    end
  end
end
