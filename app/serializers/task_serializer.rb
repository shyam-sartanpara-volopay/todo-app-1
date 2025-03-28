class TaskSerializer < BaseSerializer

  attributes :id, :title, :description, :completed, :created_at, :updated_at

  one :todo_list do
    attributes :id, :category, :status
  end
end
