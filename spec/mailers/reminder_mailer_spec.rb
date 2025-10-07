# spec/mailers/reminder_mailer_spec.rb
require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  let(:user)    { create(:user, email: "user@example.com") }
  let(:company) { create(:company) }
  let(:job)     { create(:job, user: user, company: company, title: "SE III") }

  it "sets subject for deadline reminders" do
    reminder = create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
    mail = described_class.reminder_email(reminder)
    expect(mail.to).to eq([ "user@example.com" ])
    expect(mail.subject).to match(/Application Deadline/i)
  end

  it "sets subject for interview reminders" do
    reminder = create(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: 1.day.from_now)
    mail = described_class.reminder_email(reminder)
    expect(mail.subject).to match(/Interview Reminder/i)
  end
end
