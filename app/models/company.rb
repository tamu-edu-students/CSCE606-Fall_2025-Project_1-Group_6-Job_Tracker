class Company < ApplicationRecord
    has_many :jobs, dependent: :destroy
    validates :name, presence: true
    validates :website, presence: true
end
