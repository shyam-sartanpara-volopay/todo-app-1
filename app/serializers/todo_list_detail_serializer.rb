class TodoListDetailSerializer < BaseSerializer
  attributes :id, :name, :status
  one :user, resource: UserSerializer
  many :collaborations, resource: CollaborationSerializer
end
  
