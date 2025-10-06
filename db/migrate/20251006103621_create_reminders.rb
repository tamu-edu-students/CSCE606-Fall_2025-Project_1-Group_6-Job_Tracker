class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.references :job,  null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string   :reminder_type, null: false      # "deadline" | "interview"
      t.datetime :reminder_time,  null: false
      t.boolean  :notified,       null: false, default: false
      t.boolean  :disabled,       null: false, default: false

      t.timestamps
    end

    add_index :reminders, [ :job_id, :reminder_type ]
    add_index :reminders, :reminder_time
  end
end
