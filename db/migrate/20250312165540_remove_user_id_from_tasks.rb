class RemoveUserIdFromTasks < ActiveRecord::Migration[7.1]
  def change
    remove_column :tasks, :user_id, :integer
  end
end
