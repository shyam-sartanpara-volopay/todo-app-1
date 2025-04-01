class TaskDetailSerializer < BaseSerializer
  attributes :id, :title, :description, :completed, :created_at, :updated_at

  one :todo_list, resource: TodoListMiniSerializer
end
