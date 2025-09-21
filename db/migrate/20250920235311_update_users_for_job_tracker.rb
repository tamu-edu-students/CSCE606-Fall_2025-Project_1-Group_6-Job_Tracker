class UpdateUsersForJobTracker < ActiveRecord::Migration[8.0]
  def change
    # Remove the redundant 'name' column
    remove_column :users, :name, :string

    # Only add new columns if they don't exist
    # Add notification_pref if it doesn't exist
    unless column_exists?(:users, :notification_pref)
      add_column :users, :notification_pref, :string
    end
  end
end
