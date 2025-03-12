class AddTodoListToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :todo_list, null: true, foreign_key: true
  end
end
