FactoryBot.define do
  factory :booking do
    start_date { Date.today + 7.days }
    end_date { Date.today + 10.days }
    status { "pending" }
    association :user
    association :rv_listing
  end
end
