class SendDueRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Reminder.active
      .where("reminder_time <= ? AND notified = ?", Time.current, false)
      .find_each do |reminder|
        ReminderMailer.reminder_email(reminder).deliver_later
        reminder.update!(notified: true)
      end
  end
end
