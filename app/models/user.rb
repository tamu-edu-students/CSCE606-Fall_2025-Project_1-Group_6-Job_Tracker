class User < ApplicationRecord
  # Include default Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Full name must be present
  validates :full_name, presence: true

  # Phone number must be valid and present
  validates :phone, presence: true,
            format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number (10-15 digits, optional +)" }

  # Email must be present and valid format
  validates :email, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  # Password complexity validation
  validate :password_complexity

  # Custom validation to ensure password confirmation matches password
  validate :passwords_match, if: -> { password.present? || password_confirmation.present? }

  has_many :jobs, dependent: :destroy
  has_many :reminders, dependent: :destroy

  has_one_attached :profile_photo
  validate :acceptable_image
  private

  def password_complexity
    return if password.blank?

    complexity_requirements = {
      "one lowercase letter" => /[a-z]/,
      "one uppercase letter" => /[A-Z]/,
      "one digit" => /\d/,
      "one special character" => /[^A-Za-z0-9]/
    }

    failed = complexity_requirements.map { |msg, regex| msg unless password.match?(regex) }.compact

    if password.length < 8
      errors.add :password, "must be at least 8 characters long"
    end

    if failed.any?
      errors.add :password, "must include at least #{failed.join(', ')}"
    end
  end

  def passwords_match
    if password != password_confirmation
      errors.add :password_confirmation, "doesn't match Password"
    end
  end

  def acceptable_image
    return unless profile_photo.attached?
    unless profile_photo.content_type.in?(%w[image/jpeg image/png])
      errors.add(:profile_photo, "must be a JPG or PNG")
    end
    if profile_photo.byte_size > 2.megabytes
      errors.add(:profile_photo, "is too big (max 2MB)")
    end
  end
end
