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

  after_update_commit :sync_reminders_if_status_changed

  private

  def sync_reminders_if_status_changed
    return unless saved_change_to_status?

    reminders.find_each do |reminder|
      begin
        reminder.save!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.info "Skipping invalid reminder ##{reminder.id}: #{e.message}"
      end
    end
  end


  def deadline_not_too_far
    return if deadline.blank?
    max = Date.new(2035, 12, 31)
    if deadline > max
      errors.add(:deadline, "must be on or before #{max}")
    end
  end
end
