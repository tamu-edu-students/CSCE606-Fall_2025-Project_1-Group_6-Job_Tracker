class Job < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many   :reminders, dependent: :destroy

  validates :title, presence: true
  validates :user, presence: true
  validates :company, presence: true
  validate :deadline_not_too_far

  enum :status, { to_apply: "to_apply", applied: "applied", interview: "interview", offer: "offer", rejected: "rejected" }

  scope :with_status, ->(status) { where("LOWER(status) = ?", status.to_s.downcase) }

  after_create :create_deadline_reminder
  after_update_commit :sync_reminders_if_status_changed

  private

  def sync_reminders_if_status_changed
    # Only run if the job’s status actually changed
    return unless saved_change_to_status?

    reminders.find_each do |reminder|
      reminder.save!  # triggers before_save validations and auto-disable logic
    end
  end

  def deadline_not_too_far
    return if deadline.blank?
    max = Date.new(2035, 12, 31)
    if deadline > max
      errors.add(:deadline, "must be on or before #{max}")
    end
  end

  def create_deadline_reminder
    return if deadline.blank?

    reminder_time = deadline.to_time - 6.hours

    # Only create if reminder time is still in the future
    if reminder_time > Time.current
      reminders.create!(
        user: user,
        reminder_type: "deadline",
        reminder_time: reminder_time,
        disabled: false
      )
    else
      Rails.logger.info "⚠️ Skipping reminder for Job #{id}: deadline is too close (#{deadline})"
    end
  rescue => e
    Rails.logger.error "⚠️ Failed to create reminder for job #{id}: #{e.message}"
  end
end
