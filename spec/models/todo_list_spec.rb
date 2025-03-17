require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe "Validations" do
    it "is valid with a category and user" do
      user = create(:user)
      todo_list = TodoList.new(user: user, category: "Work")
      expect(todo_list).to be_valid
    end

    it "is invalid without a category" do
      user = create(:user)
      todo_list = TodoList.new(user: user, category: nil)
      expect(todo_list).not_to be_valid
      expect(todo_list.errors[:category]).to include("can't be blank")
    end

    it "is invalid without a user" do
      todo_list = TodoList.new(user: nil)
      expect(todo_list).not_to be_valid
      expect(todo_list.errors[:user]).to include("must exist")
    end
  end

  describe "Associations" do
    it "belongs to a user" do
      expect(TodoList.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it "has many tasks" do
      expect(TodoList.reflect_on_association(:tasks).macro).to eq(:has_many)
    end
  end
end
