class ReminderMailer < ApplicationMailer
  default from: "shmishra@tamu.edu"

  def reminder_email(reminder)
    @reminder = reminder
    @user = reminder.user
    @job = reminder.job

    subject =
      case reminder.reminder_type
      when "deadline" then "📅 Application Deadline Reminder: #{@job.title}"
      when "interview" then "🎯 Interview Reminder: #{@job.title}"
      else "Job Reminder: #{@job.title}"
      end

    mail(to: @user.email, subject:)
  end
end
