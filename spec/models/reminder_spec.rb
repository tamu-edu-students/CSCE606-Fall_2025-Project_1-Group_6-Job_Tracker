# spec/models/reminder_spec.rb
require "rails_helper"

RSpec.describe Reminder, type: :model do
  let(:user)    { create(:user) }
  let(:company) { create(:company) }
  let(:job)     { create(:job, user: user, company: company, status: "to_apply", deadline: 5.days.from_now.to_date) }

  describe "associations" do
    it "belongs to user" do
      assoc = Reminder.reflect_on_association(:user)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "belongs to job" do
      assoc = Reminder.reflect_on_association(:job)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "requires reminder_type" do
      r = build(:reminder, user: user, job: job, reminder_type: nil)
      expect(r).not_to be_valid
      expect(r.errors[:reminder_type]).to be_present
    end

    it "requires reminder_time" do
      r = build(:reminder, user: user, job: job, reminder_time: nil)
      expect(r).not_to be_valid
      expect(r.errors[:reminder_time]).to be_present
    end

    it "validates inclusion of reminder_type" do
      r = build(:reminder, user: user, job: job, reminder_type: "foo")
      expect(r).not_to be_valid
      expect(r.errors[:reminder_type]).to be_present
    end

    it "does not allow reminder_time in the past" do
      r = build(:reminder, user: user, job: job, reminder_time: 2.hours.ago)
      expect(r).not_to be_valid
      expect(r.errors[:reminder_time].join).to match(/cannot be set in the past/i)
    end

    it "requires job to belong to the same user" do
      other_user = create(:user)
      other_job  = create(:job, user: other_user, company: company)
      r = build(:reminder, user: user, job: other_job)
      expect(r).not_to be_valid
      expect(r.errors[:job_id].join).to match(/must belong to the same user/i)
    end

    it "allows only one deadline reminder per job per user" do
      create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
      dup = build(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 2.days.from_now)
      expect(dup).not_to be_valid
      expect(dup.errors[:reminder_type].join).to match(/already exists/i)
    end
  end

  describe "interview_after_deadline" do
    it "requires interview reminder to be after the deadline reminder" do
      dl = create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: job.deadline.to_time.change(hour: 8))
      interview = build(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: dl.reminder_time - 1.hour)
      expect(interview).not_to be_valid
      expect(interview.errors[:reminder_time].join).to match(/before the application deadline/i)
    end

    it "is valid if interview is after the deadline reminder" do
      dl = create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: job.deadline.to_time.change(hour: 8))
      interview = build(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: dl.reminder_time + 2.hours)
      expect(interview).to be_valid
    end
  end

  describe "status-based auto-disable" do
    it "auto-disables deadline when job not in to_apply" do
      reminder = create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now, disabled: false)
      expect(reminder.disabled).to be false

      # Simulate job status change
      expect { job.update!(status: "applied") }.not_to raise_error

      reminder.reload
      expect(reminder.disabled).to be true  # ✅ auto-disabled
    end

    it "auto-disables interview reminder when job in offer or rejected" do
      create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
      interview = create(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: 2.days.from_now, disabled: false)
      expect(interview.disabled).to be false

      # Simulate job status change
      expect { job.update!(status: "offer") }.not_to raise_error

      interview.reload
      expect(interview.disabled).to be true  # ✅ auto-disabled
    end
  end

  describe "scopes" do
    it ".active returns only non-disabled" do
      a = create(:reminder, user: user, job: job, disabled: false, reminder_type: "deadline", reminder_time: 1.day.from_now)
      b = create(:reminder, user: user, job: job, disabled: true,  reminder_type: "interview", reminder_time: 2.days.from_now)
      expect(Reminder.active).to include(a)
      expect(Reminder.active).not_to include(b)
    end

    it ".upcoming returns reminders within 30 days & active" do
      near     = create(:reminder, user: user, job: job, disabled: false, reminder_time: 2.days.from_now,  reminder_type: "deadline")
      far      = create(:reminder, user: user, job: job, disabled: false, reminder_time: 40.days.from_now, reminder_type: "interview")
      disabled = create(:reminder, user: user, job: job, disabled: true,  reminder_time: 5.days.from_now, reminder_type: "interview")

      results = Reminder.upcoming
      expect(results).to include(near)
      expect(results).not_to include(far)
      expect(results).not_to include(disabled)
    end
  end

  describe "mailer callback" do
    it "enqueues mail delivery job on create (basic)" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end



