# spec/requests/jobs_export_import_spec.rb
require "rails_helper"

RSpec.describe "Jobs Import/Export (request)", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:company) { create(:company, name: "Export Co") }

  before { sign_in user }

  # -------------------------------------------------
  # Helper to simulate real CSV upload
  # -------------------------------------------------
  def upload_csv(content)
    tmp = Tempfile.new([ "jobs", ".csv" ])
    tmp.write(content)
    tmp.rewind
    Rack::Test::UploadedFile.new(tmp.path, "text/csv")
  ensure
    tmp.close
  end

  # -------------------------------------------------
  # EXPORT TESTS
  # -------------------------------------------------
  describe "GET /jobs/export" do
    it "downloads CSV with correct headers and only current user's jobs" do
      create(:job, user: user, company: company, title: "Mine", link: "https://x/1",
                   deadline: Date.today + 7, status: "applied", notes: "n")
      other_user = create(:user)
      create(:job, user: other_user, company: company, title: "Not Mine", link: "https://x/2",
                   deadline: Date.today + 8, status: "applied", notes: "n")

      get export_jobs_path

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to match(/attachment; filename="jobs-\d{8}-\d{6}\.csv"/)

      body = response.body
      header_line = body.lines.first.strip
      expect(header_line).to eq("title,company,link,deadline,status,notes")

      expect(body).to include("Mine,Export Co,https://x/1")
      expect(body).not_to include("Not Mine")
    end
  end

  # -------------------------------------------------
  # IMPORT TESTS
  # -------------------------------------------------
  describe "POST /jobs/import" do
    it "imports and redirects with success flash" do
      csv = <<~CSV
        title,company,link,deadline,status,notes
        Eng,Acme,https://a/1,2025-10-10,to_apply,n
      CSV

      post import_jobs_path, params: { file: upload_csv(csv) }
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jobs imported successfully")
      expect(response.body).to include("My Job Applications")
      expect(user.jobs.count).to eq(1)
    end

    it "shows error flash when import fails (bad headers)" do
      bad_csv = <<~CSV
        title,company,link,deadline,status
        bad headers
      CSV

      post import_jobs_path, params: { file: upload_csv(bad_csv) }
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/Import failed:/i)
      expect(user.jobs.count).to eq(0)
    end

    it "rejects when file param missing" do
      post import_jobs_path
      follow_redirect!

      expect(response.body).to include("Please choose a CSV file to import")
    end
  end
end
