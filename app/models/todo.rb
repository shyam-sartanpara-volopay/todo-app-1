class Todo < ApplicationRecord
  belongs_to :user
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: 'has already been added' }
end
