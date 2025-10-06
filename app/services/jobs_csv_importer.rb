# app/services/jobs_csv_importer.rb
require "csv"

class JobsCsvImporter
  class ImportError < StandardError; end

  HEADERS = %w[title company link deadline status notes].freeze
  MAX_ROWS = 10

  def initialize(user)
    @user = user
  end

  # content is the raw CSV string
  def import!(content)
    rows = CSV.parse(content, headers: true)
    validate_headers!(rows.headers)

    if rows.count.zero?
      raise ImportError, "CSV has no data rows."
    end

    if rows.count > MAX_ROWS
      raise ImportError, "CSV contains #{rows.count} rows; maximum allowed is #{MAX_ROWS}."
    end

    Job.transaction do
      rows.each_with_index do |row, idx|
        attrs = normalized_attributes(row, idx + 2) # +2 to account for header line
        create_job!(attrs)
      end
    end
  end

  private

  attr_reader :user

  def validate_headers!(headers)
    missing = HEADERS - headers.map { |h| h.to_s.strip.downcase }
    extra   = headers.map { |h| h.to_s.strip.downcase } - HEADERS
    raise ImportError, "CSV headers must be exactly: #{HEADERS.join(', ')}" unless missing.empty? && extra.empty?
  end

  def normalized_attributes(row, line_no)
    title    = safe(row["title"])
    company  = safe(row["company"])
    link     = safe(row["link"])
    deadline = safe(row["deadline"])
    status   = safe(row["status"])&.downcase
    notes    = row["notes"].to_s

    raise ImportError, "Line #{line_no}: title is required." if title.blank?
    raise ImportError, "Line #{line_no}: company is required." if company.blank?

    # Validate/parse deadline (optional)
    parsed_deadline =
      if deadline.present?
        begin
          Date.iso8601(deadline)
        rescue ArgumentError
          raise ImportError, "Line #{line_no}: deadline must be an ISO date (YYYY-MM-DD)."
        end
      end

    # Validate status against your enum (including 'to_apply')
    valid_statuses = Job.statuses.keys # relies on enum in Job model
    if status.present? && !valid_statuses.include?(status)
      raise ImportError, "Line #{line_no}: status must be one of #{valid_statuses.join(', ')}."
    end

    # Find or create company by name (case-insensitive)
    company_record = Company.where("LOWER(name) = ?", company.downcase).first_or_create!(name: company)

    {
      title: title,
      company: company_record,
      link: link.presence,
      deadline: parsed_deadline,
      status: status.presence || "to_apply",
      notes: notes
    }
  end

  def create_job!(attrs)
    # "Import new jobs only" → treat duplicate as an error and abort
    exists = user.jobs.where(
      title: attrs[:title],
      company_id: attrs[:company].id
    ).exists?

    raise ImportError, "Duplicate job detected: #{attrs[:title]} at #{attrs[:company].name}." if exists

    job = user.jobs.new(
      title: attrs[:title],
      company: attrs[:company],
      link: attrs[:link],
      deadline: attrs[:deadline],
      status: attrs[:status],
      notes: attrs[:notes]
    )

    unless job.save
      raise ImportError, "Validation failed for '#{attrs[:title]}' (#{attrs[:company].name}): #{job.errors.full_messages.to_sentence}"
    end
  end

  def safe(val)
    val.to_s.strip
  end
end
