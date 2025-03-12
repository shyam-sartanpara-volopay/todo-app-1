FactoryBot.define do
    factory :task do
      title { "Sample Task" }
      description { "This is a test task." }
      completed { false }
      association :todo_list
    end
  end
  