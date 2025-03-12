class Todo < ApplicationRecord
  belongs_to :todo_list
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: 'has already been added' }
end
