class TodoList < ApplicationRecord
  belongs_to :user # as user.id in Todo_lists table
  has_many :todos, dependent: :destroy # with todos table
  has_many :collaborations, dependent: :destroy # with collaborations table
  has_many :users, through: :collaborations, dependent: :destroy # with users in collaborations table
  validates :name, presence: true, uniqueness: { case_sensitive: false, message: 'has already been added' }
  enum status: { active: 'active', pending: 'pending', completed: 'completed' }
end
