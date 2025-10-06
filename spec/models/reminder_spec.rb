require "rails_helper"

RSpec.describe Reminder, type: :model do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:job) { create(:job, user: user, company: company, status: "to_apply", deadline: Date.today + 5.days) }

  it "belongs to user" do
    assoc = Reminder.reflect_on_association(:user)
    expect(assoc.macro).to eq(:belongs_to)
  end

  it "belongs to job" do
    assoc = Reminder.reflect_on_association(:job)
    expect(assoc.macro).to eq(:belongs_to)
  end

  describe "validations" do
    it "requires reminder_type" do
      r = build(:reminder, reminder_type: nil)
      expect(r).not_to be_valid
      expect(r.errors[:reminder_type]).to be_present
    end

    it "requires reminder_time" do
      r = build(:reminder, reminder_time: nil)
      expect(r).not_to be_valid
      expect(r.errors[:reminder_time]).to be_present
    end

    it "validates inclusion of reminder_type" do
      r = build(:reminder, reminder_type: "foo")
      expect(r).not_to be_valid
      expect(r.errors[:reminder_type]).to be_present
    end

    it "prevents reminder in the past" do
      r = build(:reminder, user: user, job: job, reminder_time: 1.hour.ago)
      expect(r).not_to be_valid
      expect(r.errors[:reminder_time]).to include("cannot be set in the past")
    end

    it "requires job to belong to same user" do
      other_user = create(:user)
      other_job = create(:job, user: other_user)
      r = build(:reminder, user: user, job: other_job)
      expect(r).not_to be_valid
      expect(r.errors[:job_id]).to include("must belong to the same user as the reminder")
    end

    it "allows only one deadline reminder per job per user" do
      create(:reminder, user: user, job: job, reminder_type: "deadline")
      dup = build(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
      expect(dup).not_to be_valid
      expect(dup.errors[:reminder_type].join).to match(/already exists/i)
    end
  end

  describe "interview_after_deadline" do
    it "requires interview reminder to be after deadline reminder" do
      deadline_time = (job.deadline - 0.days).in_time_zone + 6.hours # whatever your app uses
      create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: deadline_time)

      interview = build(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: deadline_time - 1.hour)
      expect(interview).not_to be_valid
      expect(interview.errors[:reminder_time].join).to match(/before the application deadline/i)
    end

    it "is valid when interview is after deadline reminder" do
      deadline_time = (job.deadline).in_time_zone + 6.hours
      create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: deadline_time)

      interview = build(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: deadline_time + 2.hours)
      expect(interview).to be_valid
    end
  end

  describe "status-based auto-disable + enforcement" do
    it "auto-disables deadline when job not in to_apply" do
      rem = build(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
      expect(rem.save).to be true
      expect(rem.disabled).to be false

      job.update!(status: "applied")
      rem.reload
      rem.save!  # triggers before_save
      expect(rem.disabled).to be true

      rem.disabled = false
      expect(rem).not_to be_valid
      expect(rem.errors[:base].join).to match(/Cannot enable deadline reminder/i)
    end

    it "auto-disables interview when job in offer or rejected" do
      # prepare interview reminder
      deadline_time = 2.days.from_now
      create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: deadline_time)

      interview = create(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: deadline_time + 1.day, disabled: false)
      expect(interview.disabled).to be false

      job.update!(status: "offer")
      interview.reload
      interview.save!
      expect(interview.disabled).to be true

      interview.disabled = false
      expect(interview).not_to be_valid
      expect(interview.errors[:base].join).to match(/Cannot enable interview reminder/i)
    end
  end

  describe "scopes" do
    it ".active returns only non-disabled" do
      a = create(:reminder, user: user, job: job, disabled: false)
      b = create(:reminder, user: user, job: job, disabled: true, reminder_time: 2.days.from_now)
      expect(Reminder.active).to include(a)
      expect(Reminder.active).not_to include(b)
    end

    it ".upcoming returns within 30 days & active" do
      a = create(:reminder, user: user, job: job, disabled: false, reminder_time: 2.days.from_now)
      create(:reminder, user: user, job: job, disabled: true, reminder_time: 3.days.from_now)
      create(:reminder, user: user, job: job, disabled: false, reminder_time: 40.days.from_now)
      expect(Reminder.upcoming).to include(a)
      expect(Reminder.upcoming).not_to include(Reminder.where(disabled: true).first)
    end
  end

  describe "mail callback" do
    it "enqueues mail on create (basic test)" do
      expect {
        create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 1.day.from_now)
      }.to have_enqueued_job.on_queue("mailers")
      # If your adapter doesn’t name 'mailers', you can instead assert:
      # expect { ... }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
