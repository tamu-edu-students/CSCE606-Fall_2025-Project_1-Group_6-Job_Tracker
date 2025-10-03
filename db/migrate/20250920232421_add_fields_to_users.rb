class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :phone, :string
    add_column :users, :location, :string
    add_column :users, :linkedin_url, :string
    add_column :users, :resume_url, :string
    add_column :users, :profile_completed, :boolean
  end
end
