class AddStatusToTodoLists < ActiveRecord::Migration[7.1]
  def change
    add_column :todo_lists, :status, :string, default: "pending"
  end
end
