require "rails_helper"

RSpec.describe "Jobs Import/Export (controller → request)", type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:user) { create(:user, email: "importer@example.com") }
  let!(:company) { create(:company, name: "Export Co") }
  let!(:job) { create(:job, user: user, company: company, title: "Export Engineer", status: "applied", link: "https://export.example/job1", deadline: Date.today + 7.days, notes: "exportable") }

  before do
    sign_in user
  end

  describe "GET /jobs/export" do
    it "downloads a CSV with correct headers and content and filename" do
      get export_jobs_path

      expect(response).to have_http_status(:ok)
      expect(response.header["Content-Type"]).to include("text/csv")

      body = response.body
      expect(body).to include("title,company,link,deadline,status,notes")
      expect(body).to include("Export Engineer")
      expect(body).to include("Export Co")

      # filename pattern
      disposition = response.header["Content-Disposition"]
      expect(disposition).to match(/attachment; filename=\"jobs-\d{8}-\d{6}\.csv\"/)
    end

    it "exports only current_user’s jobs" do
      other_user = create(:user, email: "other@example.com")
      other_company = create(:company, name: "OtherCo")
      create(:job, user: other_user, company: other_company, title: "Not Mine", status: "applied")

      get export_jobs_path
      expect(response.body).not_to include("Not Mine")
      expect(response.body).to include("Export Engineer")
    end
  end

  describe "POST /jobs/import" do
    def upload_fixture(name)
      file = Rails.root.join("spec/fixtures/files/#{name}")
      Rack::Test::UploadedFile.new(file, "text/csv")
    end

    it "imports valid CSV, creates jobs and companies, shows notice, transactional success" do
      post import_jobs_path, params: { file: upload_fixture("valid_jobs.csv") }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!

      expect(response.body).to include("Jobs imported successfully.")
      expect(Job.where(user: user).pluck(:title)).to include("Backend Developer")
      expect(Company.where("LOWER(name) = ?", "google")).to exist
    end

    it "rejects empty upload" do
      post import_jobs_path, params: { file: nil }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!
      expect(response.body).to include("Please choose a CSV file to import.")
    end

    it "rejects malformed header" do
      post import_jobs_path, params: { file: upload_fixture("invalid_header.csv") }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!
      expect(response.body).to include("Import failed:")
      expect(response.body).to include("headers must be exactly")
    end

    it "rejects > 10 rows" do
      post import_jobs_path, params: { file: upload_fixture("too_many_jobs.csv") }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!
      expect(response.body).to include("Import failed:")
      expect(response.body).to include("maximum allowed is 10")
    end

    it "rejects invalid status and rolls back all" do
      pre_count = Job.count
      post import_jobs_path, params: { file: upload_fixture("invalid_status.csv") }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!
      expect(response.body).to include("Import failed:")
      expect(Job.count).to eq(pre_count)
    end

    it "rejects malformed date" do
      post import_jobs_path, params: { file: upload_fixture("invalid_date.csv") }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!
      expect(response.body).to include("Import failed:")
      expect(response.body).to include("deadline must be an ISO date")
    end

    it "rejects duplicate job (title + company for current_user)" do
      # existing job is "Export Engineer" at "ExportCo"
      # duplicate row in CSV should abort
      post import_jobs_path, params: { file: upload_fixture("duplicate_job.csv") }
      expect(response).to redirect_to(jobs_path)
      follow_redirect!
      expect(response.body).to include("Import failed:")
      expect(response.body).to include("Duplicate job detected")
    end
  end
end
