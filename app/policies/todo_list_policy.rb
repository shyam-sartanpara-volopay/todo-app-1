class TodoListPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.left_joins(:collaborations)
           .where('todo_lists.user_id = ? OR collaborations.user_id = ?', user.id, user.id)
           .distinct
    end
  end

  def show?
    isowner? || iscollaborator?
  end

  def update?
    isowner? || iscollaborator?
  end

  def destroy?
    isowner?
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