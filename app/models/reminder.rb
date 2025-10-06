class Reminder < ApplicationRecord
  belongs_to :job
  belongs_to :user

  # -------------------
  # VALIDATIONS
  # -------------------
  validates :reminder_type, presence: true, inclusion: { in: %w[deadline interview] }
  validates :reminder_time, presence: true
  validate  :job_belongs_to_user
  validate  :interview_after_deadline
  validate  :reminder_not_in_past
  validate  :single_deadline_per_job

  # -------------------
  # SCOPES
  # -------------------
  scope :active, -> { where(disabled: false) }
  scope :upcoming, -> {
    active
      .where("reminder_time >= ? AND reminder_time <= ?", Time.zone.now, 30.days.from_now)
      .order(:reminder_time)
  }

  after_create_commit :send_creation_email

  # -------------------
  # INSTANCE METHODS
  # -------------------
  def mark_notified!
    update(notified: true)
  end

  private

  # ✅ Validation: reminder's job must belong to same user
  def job_belongs_to_user
    return if job.nil?
    if job.user_id != user_id
      errors.add(:job_id, "must belong to the same user as the reminder")
    end
  end

  # ✅ Validation: reminders cannot be set in the past
  def reminder_not_in_past
    return if reminder_time.blank?
    if reminder_time < Time.zone.now
      errors.add(:reminder_time, "cannot be set in the past")
    end
  end

  # ✅ Validation: interview reminder must be after deadline reminder AND current time
  def interview_after_deadline
    return unless reminder_type == "interview"
    return if reminder_time.blank?

    # Ensure interview reminder isn't before today
    if reminder_time < Time.zone.now
      errors.add(:reminder_time, "cannot be before the current time")
      return
    end

    # Ensure interview reminder isn't before the deadline reminder
    deadline_reminder = Reminder.find_by(job_id: job_id, reminder_type: "deadline")
    if deadline_reminder && reminder_time < deadline_reminder.reminder_time
      errors.add(:reminder_time, "cannot be before the application deadline reminder")
    end
  end

  # ✅ NEW Validation: only one deadline reminder per job per user
  def single_deadline_per_job
    return unless reminder_type == "deadline"

    existing = Reminder.where(job_id: job_id, user_id: user_id, reminder_type: "deadline").where.not(id: id)
    if existing.exists?
      errors.add(:reminder_type, "reminder already exists for this job")
    end
  end

  def send_creation_email
    ReminderMailer.reminder_email(self).deliver_later
  end
end
