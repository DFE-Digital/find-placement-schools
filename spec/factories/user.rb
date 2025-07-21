FactoryBot.define do
  factory :user do
    first_name { "Judith" }
    last_name { "Chicken" }
    email_address { "judith.chicken@hogwarts.sch.uk" }
    dfe_sign_in_uid { SecureRandom.uuid }
  end
end
