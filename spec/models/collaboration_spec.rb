require 'rails_helper'

RSpec.describe Collaboration, type: :model do
  let!(:owner) { create(:user) } # Owner of the todo_list
  let!(:collaborator) { create(:user) } # Separate user as collaborator
  let!(:todo_list) { create(:todo_list, user: owner) } # Owned by 'owner'
  let!(:collaboration) { create(:collaboration, user: collaborator, todo_list: todo_list) } # Collaborator is different

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:todo_list) }
  end

  describe "validations" do
    it "validates uniqueness of user_id scoped to todo_list_id" do
      duplicate_collaboration = Collaboration.new(user: collaborator, todo_list: todo_list)
      duplicate_collaboration.valid?
      expect(duplicate_collaboration.errors[:user_id]).to include("is already a collaborator for this todo list")
    end
  end
end
