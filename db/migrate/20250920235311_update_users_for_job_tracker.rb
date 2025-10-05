class UpdateUsersForJobTracker < ActiveRecord::Migration[8.0]
  def change
    # Remove the redundant 'name' column
    remove_column :users, :name, :string
  end
end
