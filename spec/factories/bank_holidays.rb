FactoryBot.define do
  factory :bank_holiday do
    date { Date.parse("2024-12-25") }
    title { "Christmas Day" }
  end
end
