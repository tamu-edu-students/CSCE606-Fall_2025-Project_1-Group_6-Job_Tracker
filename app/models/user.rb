class User < ApplicationRecord
  # Devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations for the new fields
  validates :full_name, presence: true
  validates :phone, format: { with: /\A\+?\d{10,15}\z/,
                              message: 'must be a valid phone number' },
            allow_blank: true
  validates :linkedin_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
            allow_blank: true
  validates :resume_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
            allow_blank: true

  has_many :jobs, dependent: :destroy

end