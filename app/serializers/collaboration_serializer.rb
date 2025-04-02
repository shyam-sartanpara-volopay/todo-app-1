class CollaborationSerializer < BaseSerializer
  attribute :email do |collaboration|
    collaboration.user.email
  end

  attribute :todo_list_name do |collaboration|
    collaboration.todo_list.name
  end
end
