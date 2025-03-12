class TodoList < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false, message: 'has already been added' }
end
