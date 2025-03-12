FactoryBot.define do
    factory :todo_list do
      association :user
      category { "Personal" }
    end
end