class TodoSerializer
  include Alba::Resource
  attributes :id, :title, :description, :done
end