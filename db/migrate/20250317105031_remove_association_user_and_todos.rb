class RemoveAssociationUserAndTodos < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :todos, :users
    remove_reference :todos, :user, index: true
  end
end
