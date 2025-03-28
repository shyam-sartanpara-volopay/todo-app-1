class CollaborationSerializer < BaseSerializer

  attributes :id, :user_id, :todo_list_id, :created_at, :updated_at

  one :user do
    attributes :id, :name, :email
  end

  one :todo_list do
    attributes :id, :category, :status
  end
end
