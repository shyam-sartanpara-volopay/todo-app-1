class TodoPolicy < ApplicationPolicy
  def show?
    isowner? || iscollaborator?
  end

  def create?
    isowner? || iscollaborator?
  end

  def update?
    isowner? || iscollaborator?
  end

  def destroy?
    isowner? || iscollaborator?
  end

  private

  def isowner?
    record.todo_list.user_id == user.id
  end

  def iscollaborator?
    record.todo_list.collaborations.exists?(user_id: user.id)
  end
end
