require 'rails_helper'
require 'cgi'

RSpec.describe 'Companies CRUD', type: :request do
  let(:user) { User.create!(email: 'comp@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'CompUser', phone: '+12345678909') }
  let(:valid_attrs) { { name: 'NewCo', website: 'https://newco.example' } }
  before { login_as(user, scope: :user) }

  it 'GET /companies returns success' do
    get companies_path
    expect(response).to have_http_status(:ok)
  end

  it 'GET /companies/:id returns success and shows only current user jobs' do
    company = Company.create!(name: 'ShowCo', website: 'https://showco.example')
    other_user = User.create!(email: 'o@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'O', phone: '+12345678908')
    Job.create!(title: 'Mine', user: user, company: company)
    Job.create!(title: 'Other', user: other_user, company: company)
    get company_path(company)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Mine')
    expect(response.body).not_to include('Other')
  end

  it 'GET /companies/new returns success' do
    get new_company_path
    expect(response).to have_http_status(:ok)
  end

  it 'POST /companies creates a company and redirects to companies index' do
    expect {
      post companies_path, params: { company: valid_attrs }
    }.to change(Company, :count).by(1)
    expect(response).to redirect_to(companies_path)
  end

  it 'POST /companies with return_to jobs_new redirects to new_job_path' do
    post companies_path, params: { company: valid_attrs, return_to: 'jobs_new' }
    expect(response).to redirect_to(new_job_path)
  end

  it 'POST /companies with invalid attrs renders new with errors' do
    post companies_path, params: { company: { name: '', website: '' } }
    expect(response).to have_http_status(:unprocessable_entity)
    # response body HTML-escapes apostrophes (can&#39;t). Unescape before checking.
    expect(CGI.unescapeHTML(response.body)).to include("can't be blank")
  end
end
