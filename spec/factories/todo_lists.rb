FactoryBot.define do
  factory :todo_list do
    name { Faker::Lorem.word }
    association :user
  end
end
