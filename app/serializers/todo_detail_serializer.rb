class TodoDetailSerializer
  include Alba::Resource

  one :todo_list, resource: TodoListSerializer

  attributes :id, :title, :description, :done
end