require "rails_helper"

RSpec.describe JobsCsvImporter do
  let(:user) { create(:user) }

  def load_fixture(name)
    File.read(Rails.root.join("spec/fixtures/files/#{name}"))
  end

  it "imports a valid CSV" do
    csv = load_fixture("valid_jobs.csv")
    expect {
      described_class.new(user).import!(csv)
    }.to change { Job.where(user: user).count }.by(1)
    expect(Company.where("LOWER(name)=?", "google")).to exist
  end

  it "raises on invalid header" do
    csv = load_fixture("invalid_header.csv")
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /headers/i)
  end

  it "raises when more than 10 rows" do
    csv = load_fixture("too_many_jobs.csv")
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /maximum allowed is 10/i)
  end

  it "raises on invalid status" do
    csv = load_fixture("invalid_status.csv")
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /status must be one of/i)
  end

  it "raises on malformed date" do
    csv = load_fixture("invalid_date.csv")
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /deadline must be an ISO date/i)
  end

  it "raises on duplicate job (all rolled back)" do
    # seed an existing job
    company = Company.create!(name: "ExportCo")
    Job.create!(user: user, company: company, title: "Export Engineer", status: "applied")

    csv = load_fixture("duplicate_job.csv")
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /Duplicate job detected/)
  end
end
