class AddNotesToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :notes, :text
  end
end
