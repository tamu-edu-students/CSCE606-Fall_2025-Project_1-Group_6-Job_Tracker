require 'rails_helper'

RSpec.describe 'Jobs CRUD', type: :request do
  let!(:user) { User.create!(email: 'u@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U', phone: '+12345678901') }
  let!(:company) { Company.create!(name: 'TestCo') }

  it 'lists jobs' do
    job = Job.create!(title: 'ListMe', user: user, company: company)
    get jobs_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('ListMe')
  end

  it 'creates a job with valid attributes' do
    post jobs_path, params: { job: { title: 'CreateMe', user_id: user.id, company_id: company.id } }
    expect(response).to redirect_to(jobs_path)
    expect(Job.find_by(title: 'CreateMe')).not_to be_nil
  end

  it 'does not create a job with nil title' do
    post jobs_path, params: { job: { title: nil, user_id: user.id, company_id: company.id } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(Job.find_by(title: nil)).to be_nil
  end

  it 'shows a job' do
    job = Job.create!(title: 'ShowMe', user: user, company: company)
    get job_path(job)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('ShowMe')
  end

  it 'updates a job' do
    job = Job.create!(title: 'Old', user: user, company: company)
    patch job_path(job), params: { job: { title: 'Updated' } }
    expect(response).to redirect_to(jobs_path)
    expect(job.reload.title).to eq('Updated')
  end

  it 'deletes a job' do
    job = Job.create!(title: 'Bye', user: user, company: company)
    delete job_path(job)
    expect(response).to redirect_to(jobs_path)
    expect(Job.find_by(id: job.id)).to be_nil
  end
end
