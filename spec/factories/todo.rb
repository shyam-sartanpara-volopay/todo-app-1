FactoryBot.define do
  factory :todo do
    title { Faker::Lorem.sentence }
    association :todo_list
  end
end
