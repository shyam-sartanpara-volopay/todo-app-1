class TodoList < ApplicationRecord
  belongs_to :user
  
  has_many :tasks, dependent: :destroy
  validates :category, presence: true
  validates :status, presence:true, inclusion: { in: %w[pending in_progress completed] }

  enum status: {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed"
  }

end
