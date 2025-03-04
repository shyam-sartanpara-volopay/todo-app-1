class ModifycolTodosTable < ActiveRecord::Migration[7.1]
  def change
    change_column_default :todos, :done, from: true, to: false
  end
end
