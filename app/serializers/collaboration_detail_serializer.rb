class CollaborationDetailSerializer < BaseSerializer
  attributes :id, :user_id, :todo_list_id, :created_at, :updated_at

  one :user, resource: UserMiniSerializer

  one :todo_list, resource: TodoListMiniSerializer
end
