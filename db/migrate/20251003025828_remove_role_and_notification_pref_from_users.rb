class RemoveRoleAndNotificationPrefFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :role, :string
    remove_column :users, :notification_pref, :string
  end
end
