class TodoListPolicy < ApplicationPolicy

  def index?
    authorized?
  end

  def show?
    authorized?
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

  def authorized?
    user_is_owner? || user_is_collaborator?
  end

  def user_is_owner?
    record.user_id == user.id
  end

  def user_is_collaborator?
    record.collaborations.exists?(user_id: user.id)
  end

end
