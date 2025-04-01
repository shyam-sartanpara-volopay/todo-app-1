class TodoListDetailSerializer < BaseSerializer
  attributes :id, :category, :status, :created_at, :updated_at

  one :user, resource: UserMiniSerializer

  many :tasks, resource: TaskMiniSerializer

  many :collaborators, resource: UserMiniSerializer
end
