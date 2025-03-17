FactoryBot.define do
  factory :todo do
    sequence(:title) { |n| "Test Todo #{n}" }
    done { false }
    description { Faker::Lorem.sentence(word_count: 10) }
    association :todo_list
  end
end
