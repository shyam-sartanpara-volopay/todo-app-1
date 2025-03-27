FactoryBot.define do
  factory :collaboration do
    association :user
    association :todo_list
  end
end
