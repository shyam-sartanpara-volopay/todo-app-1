FactoryBot.define do
  factory :todo_list do
    sequence(:name) { |n| "Todo List #{n}" } # Ensures each name is unique as we validate each name as unique
    association :user
  end
end
