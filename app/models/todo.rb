class Todo < ApplicationRecord
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: 'has already been added' }
end
