class Collaboration < ApplicationRecord
  belongs_to :user # for user.id in Collaboration table
  belongs_to :todo_list # for todolist.id in Collaboration table
  validates :user_id, uniqueness: { scope: :todo_list_id, message: 'is already a collaborator' }
  validate :owner_cannot_be_a_collaborator

  private

  def owner_cannot_be_a_collaborator
    if user_id == todo_list.user_id
      errors.add(:base, 'Owner cannot be a collaborator')
    end
  end
end
