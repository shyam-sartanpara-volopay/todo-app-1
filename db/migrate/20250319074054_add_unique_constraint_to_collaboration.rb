class AddUniqueConstraintToCollaboration < ActiveRecord::Migration[7.1]
  def change
    add_index :collaborations, %i[user_id todo_list_id], unique: true
  end
end
