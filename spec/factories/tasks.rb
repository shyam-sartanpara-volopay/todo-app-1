FactoryBot.define do
    factory :task do
      title { "Sample Task" }
      description { "This is a test task." }
      completed { false }
    end
  end
  