class Company < ApplicationRecord
  has_many :jobs, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :website, allow_blank: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: -> { website.present? }

  before_save :normalize_name

  private

  def normalize_name
    self.name = name.strip.titleize
  end
end
