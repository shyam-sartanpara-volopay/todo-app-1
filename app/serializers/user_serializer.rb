class UserSerializer
  include Alba::Resource

  attributes :id, :name, :email, :created_at, :updated_at

  many :todo_lists do
    attributes :id, :category, :status, :created_at, :updated_at
  end

  many :shared_todo_lists do
    attributes :id, :category, :status, :created_at, :updated_at
  end
end
