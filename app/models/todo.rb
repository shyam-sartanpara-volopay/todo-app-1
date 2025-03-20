class Todo < ApplicationRecord
  belongs_to :todo_list # for todo_list.id in todos table
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: 'has already been added' }
end
