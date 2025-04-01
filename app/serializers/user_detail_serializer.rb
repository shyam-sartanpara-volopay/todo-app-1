class UserDetailSerializer < BaseSerializer
  attributes :id, :name, :email, :created_at, :updated_at

  many :todo_lists, resource: TodoListMiniSerializer

  many :shared_todo_lists, resource: TodoListMiniSerializer
end
