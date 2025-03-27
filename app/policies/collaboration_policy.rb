class CollaborationPolicy < ApplicationPolicy
  
  def index?
    user_is_owner?
  end

  def show?
    user_is_owner?
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

  def user_is_owner?
    record.todo_list.user_id == user.id
  end
end
