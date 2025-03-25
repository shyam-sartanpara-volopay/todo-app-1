class CollaborationPolicy < ApplicationPolicy
  def index?
    isowner? || iscollaborator?
  end
  

  def create? 
    isowner?
  end

  def destroy?  
    isowner?
  end

  private

  def isowner?
    record.user_id == user.id
  end

  def iscollaborator?
    record.collaborations.exists?(user_id: user.id)
  end
end
