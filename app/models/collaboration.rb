class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :todo_list

  validates :user_id, uniqueness: { scope: :todo_list_id, message: "is already a collaborator for this todo list" }

  validate :user_cannot_be_owner


  private
  #user who owns todo_list cannot be collaborator
  def user_cannot_be_owner

    return if todo_list.nil?

    if todo_list.user_id == user_id
      errors.add(:user_id, "cannot be a collaborator on their own todo list")
    end
  end

end
