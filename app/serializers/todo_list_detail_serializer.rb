class TodoListDetailSerializer
  include Alba::Resource

  attributes :id, :name, :status

  one :user do
    attributes :id, :name, :email
  end

  many :collaborators do
    attributes :id, :name, :email
  end
end
  
