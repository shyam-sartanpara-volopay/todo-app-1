class AddStatusToTodoList < ActiveRecord::Migration[7.1]
  def change
    add_column :todo_lists, :status, :string, default: 'active', null: false
  end
end
