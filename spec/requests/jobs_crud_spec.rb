require 'rails_helper'

RSpec.describe 'Jobs CRUD', type: :request do
  let!(:user) { User.create!(email: 'u@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U', phone: '+12345678901') }
  let!(:company) { Company.create!(name: 'TestCo', website: 'https://testco.example') }
  before { login_as(user, scope: :user) }

  it 'lists jobs' do
    job = Job.create!(title: 'ListMe', user: user, company: company)
    get jobs_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('ListMe')
  end

  it 'creates a job with valid attributes' do
  post jobs_path, params: { job: { title: 'CreateMe', user_id: user.id, company_id: company.id } }
  expect(response).to redirect_to(dashboard_path)
    expect(Job.find_by(title: 'CreateMe')).not_to be_nil
  end

  it 'does not create a job with nil title' do
    post jobs_path, params: { job: { title: nil, user_id: user.id, company_id: company.id } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(Job.find_by(title: nil)).to be_nil
  end

  it 'does not create a job with nil company' do
    post jobs_path, params: { job: { title: 'NoCompany', user_id: user.id, company_id: nil } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(Job.find_by(title: 'NoCompany')).to be_nil
  end

  it 'rejects malformed deadline' do
    post jobs_path, params: { job: { title: 'BadDate', user_id: user.id, company_id: company.id, deadline: 'not-a-date' } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(Job.find_by(title: 'BadDate')).to be_nil
  end

  it 'rejects deadline beyond 2035' do
    post jobs_path, params: { job: { title: 'FarDate', user_id: user.id, company_id: company.id, deadline: '2040-01-01' } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(Job.find_by(title: 'FarDate')).to be_nil
  end

  it 'shows a job' do
    job = Job.create!(title: 'ShowMe', user: user, company: company)
    get job_path(job)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('ShowMe')
  end

  it 'updates a job' do
    job = Job.create!(title: 'Old', user: user, company: company)
  patch job_path(job), params: { job: { title: 'Updated' }, from: 'dashboard' }
  expect(response).to redirect_to(dashboard_path)
    expect(job.reload.title).to eq('Updated')
  end

  it 'deletes a job' do
    job = Job.create!(title: 'Bye', user: user, company: company)
  delete job_path(job), params: { from: 'dashboard' }
  expect(response).to redirect_to(dashboard_path)
    expect(Job.find_by(id: job.id)).to be_nil
  end
end
