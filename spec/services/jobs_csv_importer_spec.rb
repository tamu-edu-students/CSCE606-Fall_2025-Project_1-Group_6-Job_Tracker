# spec/services/jobs_csv_importer_spec.rb
require "rails_helper"

RSpec.describe JobsCsvImporter, type: :service do
  let(:user) { create(:user) }

  def csv_of(rows)
    header = "title,company,link,deadline,status,notes\n"
    header + rows.map { |r| [ r[:title], r[:company], r[:link], r[:deadline], r[:status], r[:notes] ].join(",") }.join("\n") + "\n"
  end

  it "imports up to MAX_ROWS rows for the current user and creates companies" do
    csv = csv_of([
      { title: "Eng 1", company: "Acme", link: "https://ac.me/j1", deadline: "2025-10-10", status: "to_apply", notes: "n1" },
      { title: "Eng 2", company: "Acme", link: "https://ac.me/j2", deadline: "2025-10-11", status: "applied",  notes: "n2" },
      { title: "PM 1",  company: "Globex", link: "https://glx.me/j3", deadline: "2025-10-12", status: "interview", notes: "n3" }
    ])

    expect {
      described_class.new(user).import!(csv)
    }.to change { Job.where(user: user).count }.by(3)
     .and change { Company.count }.by(2)

    titles = user.jobs.order(:created_at).pluck(:title)
    expect(titles).to include("Eng 1", "Eng 2", "PM 1")
  end

  it "raises on missing headers" do
    bad_csv = "title,company,link,deadline,status\nWrong header row\n"
    expect {
      described_class.new(user).import!(bad_csv)
    }.to raise_error(JobsCsvImporter::ImportError, /CSV headers must be exactly: title, company, link, deadline, status, notes/)
  end

  it "raises on extra headers" do
    bad_csv = "title,company,link,deadline,status,notes,extra\nRow\n"
    expect {
      described_class.new(user).import!(bad_csv)
    }.to raise_error(JobsCsvImporter::ImportError,  /CSV headers must be exactly: title, company, link, deadline, status, notes/)
  end

  it "rolls back when more than MAX_ROWS" do
    rows = (1..(JobsCsvImporter::MAX_ROWS + 1)).map do |i|
      { title: "T#{i}", company: "C#{i}", link: "https://x/#{i}", deadline: "2025-10-10", status: "to_apply", notes: "n" }
    end
    csv = csv_of(rows)

    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /maximum allowed is #{JobsCsvImporter::MAX_ROWS}/i)
    expect(Job.where(user: user).count).to eq(0)
  end

  it "raises on duplicate job for same user (title + company)" do
    csv = csv_of([
      { title: "Dup", company: "Acme", link: "https://ac.me/j1", deadline: "2025-10-10", status: "to_apply", notes: "" },
      { title: "Dup", company: "Acme", link: "https://ac.me/j2", deadline: "2025-10-11", status: "applied",  notes: "" }
    ])
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /Duplicate job detected/)
    expect(Job.where(user: user).count).to eq(0) # rolled back
  end

  it "raises on invalid status" do
    csv = csv_of([
      { title: "Eng", company: "Acme", link: "https://ac.me/j1", deadline: "2025-10-10", status: "open", notes: "" }
    ])
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /status must be one of to_apply, applied, interview, offer, rejected/)
  end

  it "raises on invalid date format" do
    csv = csv_of([
      { title: "Eng", company: "Acme", link: "https://ac.me/j1", deadline: "10/10/2025", status: "applied", notes: "" }
    ])
    expect {
      described_class.new(user).import!(csv)
    }.to raise_error(JobsCsvImporter::ImportError, /deadline must be an ISO date/)
  end
end
