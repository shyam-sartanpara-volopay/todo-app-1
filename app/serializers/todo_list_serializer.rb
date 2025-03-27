class TodoListSerializer
  include Alba::Resource

  attributes :id, :category, :status, :created_at, :updated_at

  one :user do
    attributes :id, :name, :email
  end

  many :tasks do
    attributes :id, :title, :description, :completed, :created_at, :updated_at
  end

  many :collaborators do
    attributes :id, :name, :email
  end
end
