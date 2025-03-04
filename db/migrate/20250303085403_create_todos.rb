class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :done, default: false, null: false

      t.timestamps
    end
  end
end
