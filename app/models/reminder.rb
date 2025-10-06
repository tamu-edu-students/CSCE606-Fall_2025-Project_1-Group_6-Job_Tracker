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
  validate  :enforce_status_based_rules

  # -------------------
  # SCOPES
  # -------------------
  scope :active, -> { where(disabled: false) }
  scope :upcoming, -> {
    active
      .where("reminder_time >= ? AND reminder_time <= ?", Time.zone.now, 30.days.from_now)
      .order(:reminder_time)
  }

  # -------------------
  # CALLBACKS
  # -------------------
  after_create_commit :send_creation_email
  before_save :auto_disable_based_on_job_status

  # -------------------
  # INSTANCE METHODS
  # -------------------
  def mark_notified!
    update(notified: true)
  end

  private

  # ✅ Reminder's job must belong to same user
  def job_belongs_to_user
    return if job.nil?
    errors.add(:job_id, "must belong to the same user as the reminder") if job.user_id != user_id
  end

  # ✅ Cannot schedule reminders in the past
  def reminder_not_in_past
    return if reminder_time.blank?
    errors.add(:reminder_time, "cannot be set in the past") if reminder_time < Time.zone.now
  end

  # ✅ Interview reminder must be after deadline reminder
  def interview_after_deadline
    return unless reminder_type == "interview"
    return if reminder_time.blank?

    if reminder_time < Time.zone.now
      errors.add(:reminder_time, "cannot be before the current time")
      return
    end

    deadline_reminder = Reminder.find_by(job_id: job_id, reminder_type: "deadline")
    if deadline_reminder && reminder_time < deadline_reminder.reminder_time
      errors.add(:reminder_time, "cannot be before the application deadline reminder")
    end
  end

  # ✅ Only one deadline reminder per job per user
  def single_deadline_per_job
    return unless reminder_type == "deadline"

    existing = Reminder.where(job_id: job_id, user_id: user_id, reminder_type: "deadline").where.not(id: id)
    if existing.exists?
      errors.add(:reminder_type, "reminder already exists for this job")
    end
  end

  # ✅ Disable reminders automatically based on job status
  def auto_disable_based_on_job_status
    return if job.blank?

    case reminder_type
    when "deadline"
      # Disable if job not in 'to_apply'
      self.disabled = true unless job.status == "to_apply"
    when "interview"
      # Disable if job in 'offer' or 'rejected'
      self.disabled = true if %w[offer rejected].include?(job.status)
    end
  end

  # ✅ Prevent enabling invalid reminders manually
  def enforce_status_based_rules
    return if job.blank?

    if reminder_type == "deadline"
      if job.status != "to_apply" && disabled == false
        errors.add(:base, "Cannot enable deadline reminder unless job is in 'To Apply' status")
      end
    elsif reminder_type == "interview"
      if %w[offer rejected].include?(job.status) && disabled == false
        errors.add(:base, "Cannot enable interview reminder when job is in Offer or Rejected status")
      end
    end
  end

  # ✅ Send email asynchronously
  def send_creation_email
    ReminderMailer.reminder_email(self).deliver_later
  end
end