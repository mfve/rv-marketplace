FactoryBot.define do
  factory :rv_listing do
    title { "Beautiful RV" }
    description { "A cozy RV perfect for weekend getaways" }
    location { "Sydney, NSW" }
    price_per_day { 150.00 }
    association :user
  end
end
