FactoryBot.define do
  factory :todo do
    sequence(:title) { |n| "Test Todo #{n}" }
    description { Faker::Lorem.sentence(word_count: 10) }
    done { false }
    association :user
  end
end
