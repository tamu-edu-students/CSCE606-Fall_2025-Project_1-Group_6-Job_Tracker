class Job < ApplicationRecord
  belongs_to :user
  belongs_to :company

  scope :with_status, ->(status) { where("LOWER(status) = ?", status.to_s.downcase) }
end
