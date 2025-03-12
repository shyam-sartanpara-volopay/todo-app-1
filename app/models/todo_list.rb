class TodoList < ApplicationRecord
  belongs_to :user
  
  has_many :tasks, dependent: :destroy
  validates :category, presence: true
end
