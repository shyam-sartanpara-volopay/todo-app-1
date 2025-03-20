class Collaboration < ApplicationRecord
  belongs_to :user # for user.id in Collaboration table
  belongs_to :todo_list # for todolist.id in Collaboration table
end
