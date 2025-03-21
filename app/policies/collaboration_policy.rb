class CollaborationPolicy < ApplicationPolicy
  def index
    isowner?
  end
  def create?
    isowner?
  end

  def destroy?
    isowner?
  end

  private

  def isowner?
    record.todo_list.user_id == user.id
  end

  # def iscollaborator?
  #   record.todo_list.collaborations.exists?(user_id: user.id)
  # end
end
