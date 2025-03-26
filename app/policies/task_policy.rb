class TaskPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:todo_list)
           .left_joins(todo_list: :collaborations)
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
    has_access?
  end

  def update?
    has_access?
  end

  def destroy?
    user_is_owner?
  end

  private

  def has_access?
    user_is_owner? || user_is_collaborator?
  end

  def user_is_owner?
    record.todo_list.user_id == user.id
  end

  def user_is_collaborator?
    Collaboration.where(user_id: user.id, todo_list_id: record.todo_list_id).limit(1).exists?
  end
  
end
