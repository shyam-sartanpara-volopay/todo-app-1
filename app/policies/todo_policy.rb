class TodoPolicy < ApplicationPolicy
  def index?
    isowner? || iscollaborator?
  end
    
  def show?
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
    record.user_id == user.id
  end

  def iscollaborator?
    record.collaborations.exists?(user_id: user.id)
  end
end
