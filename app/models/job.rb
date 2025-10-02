class Job < ApplicationRecord
  belongs_to :user
  belongs_to :company
  validates :title, presence: true
  validates :user, presence: true
  validates :company, presence: true
  validate :deadline_not_too_far

  private

  def deadline_not_too_far
    return if deadline.blank?
    max = Date.new(2035, 12, 31)
    if deadline > max
      errors.add(:deadline, "must be on or before #{max}")
    end
  end
end
