class AddDefaultToJobStatus < ActiveRecord::Migration[7.1]
  def change
    change_column_default :jobs, :status, from: nil, to: "to_apply"
  end
end
