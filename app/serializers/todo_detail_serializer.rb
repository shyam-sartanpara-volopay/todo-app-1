class TodoDetailSerializer < BaseSerializer
  one :todo_list, resource: TodoListSerializer

  attributes :id, :title, :description, :done
end