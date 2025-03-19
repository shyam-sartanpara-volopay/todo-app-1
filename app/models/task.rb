class Task < ApplicationRecord
    belongs_to :todo_list

    has_many :collaborations, through: :todo_list

    validates :title, presence: true
    validates :completed, inclusion: { in: [true, false] }
end
