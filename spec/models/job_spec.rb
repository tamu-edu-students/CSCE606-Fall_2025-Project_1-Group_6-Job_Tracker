# spec/models/job_spec.rb
require "rails_helper"

RSpec.describe Job, type: :model do
  let(:user)    { create(:user) }
  let(:company) { create(:company) }

  it "is valid with title, user and company" do
    j = build(:job, user: user, company: company, title: "Eng")
    expect(j).to be_valid
  end

  it "is invalid without a title" do
    j = build(:job, user: user, company: company, title: nil)
    expect(j).not_to be_valid
  end

  it "rejects deadlines beyond 2035-12-31" do
    j = build(:job, user: user, company: company, deadline: Date.new(2036,1,1))
    expect(j).not_to be_valid
    expect(j.errors[:deadline].join).to match(/on or before 2035-12-31/)
  end

  it "supports enum statuses including to_apply" do
    j = build(:job, user: user, company: company, status: "to_apply")
    expect(j).to be_valid
    expect(Job.statuses.keys).to include("to_apply", "applied", "interview", "offer", "rejected")
  end

  it "scopes with_status case-insensitively" do
    create(:job, user: user, company: company, status: "applied")
    expect(Job.with_status("APPLIED").count).to eq(1)
  end

  it "after_update_commit syncs reminders when status changes" do
    job = create(:job, user: user, company: company, status: "to_apply", deadline: 5.days.from_now.to_date)
    r1  = create(:reminder, user: user, job: job, reminder_type: "deadline", reminder_time: 2.days.from_now)
    r2  = create(:reminder, user: user, job: job, reminder_type: "interview", reminder_time: 3.days.from_now)

    # Should not raise when job status changes; callback saves reminders
    expect { job.update!(status: "applied") }.not_to raise_error

    # By now, deadline reminder should be auto-disabled (enforced by Reminder model)
    expect(r1.reload.disabled).to be(true)
  end
end
