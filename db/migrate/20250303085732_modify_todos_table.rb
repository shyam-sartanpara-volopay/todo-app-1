class ModifyTodosTable < ActiveRecord::Migration[7.1]
  def change
    change_column_default :todos, :done, from: false, to: true
    change_column_null :todos, :title, false
    change_column_null :todos, :done, false
  end
end
