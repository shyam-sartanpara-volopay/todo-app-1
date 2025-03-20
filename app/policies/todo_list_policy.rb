class TodoListPolicy < ApplicationPolicy
  def show?
    isowner? || iscollaborator?
  end

  def create?
    isowner?
  end

  def update?
    isowner? || iscollaborator?
  end

  def destroy?
    isowner?
  end

  def access_collaboration?
    isowner?
  end

  def access_todos?
    isowner? || iscollaborator?
  end

  private

  # record --> todolist
  def isowner?
    record.user_id == user.id
  end

  def iscollaborator?
    record.collaborations.exists?(user_id: user.id)
  end
end