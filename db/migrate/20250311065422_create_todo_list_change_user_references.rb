class CreateTodoListChangeUserReferences < ActiveRecord::Migration[7.1]
  def change
    create_table :todo_lists do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Adding todo_list reference to todos
    change_table :todos do |t|
      t.references :todo_list, null: false, foreign_key: true
    end
  end
end
