class TodoListPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      scope.left_joins(:collaborations)
           .where("todo_lists.user_id = ? OR collaborations.user_id = ?", user.id, user.id)
           .distinct
    end
  end

  def index?
    has_access?
  end

  def show?
    has_access?
  end

  def create?
    user_is_owner?
  end

  def update?
    user_is_owner?
  end

  def destroy?
    user_is_owner?
  end

  private

  def has_access?
    user_is_owner? || user_is_collaborator?
  end

  def user_is_owner?
    record.user_id == user.id
  end

  def user_is_collaborator?
    record.collaborations.exists?(user_id: user.id)
  end

end
