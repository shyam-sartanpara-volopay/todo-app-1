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

  has_many :collaborations, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user

end
