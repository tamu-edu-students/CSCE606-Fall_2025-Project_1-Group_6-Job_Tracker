class Job < ApplicationRecord
  belongs_to :user
  belongs_to :company
  validates :title, presence: true
  validates :user, presence: true
  validates :company, presence: true
end
