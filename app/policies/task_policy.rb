class TaskPolicy < ApplicationPolicy

  def show?
    authorized?
  end

  def create?
    authorized?
  end

  def update?
    authorized?
  end

  def destroy?
    user_is_owner?
  end

  private

  def authorized?
    user_is_owner? || user_is_collaborator?
  end

  def user_is_owner?
    record.todo_list.user_id == user.id
  end

  def user_is_collaborator?
    record.todo_list.collaborations.exists?(user_id: user.id)
  end
end
