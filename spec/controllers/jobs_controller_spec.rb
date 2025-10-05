require 'rails_helper'

RSpec.describe 'Jobs (controller → request)', type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'Test User', phone: '+12345678901') }
  let(:company) { Company.create!(name: 'TestCo', website: 'https://testco.com') }
  let(:valid_attributes) do
    { title: 'Developer', company_id: company.id, link: 'https://job.com', deadline: Date.today + 7, notes: 'Remote', status: 'applied' }
  end

  before { login_as(user, scope: :user) }

  it 'GET /jobs returns success' do
    Job.create!(valid_attributes.merge(user: user))
    get jobs_path
    expect(response).to be_successful
  end

  it 'GET /jobs/:id returns success' do
    job = Job.create!(valid_attributes.merge(user: user))
    get job_path(job)
    expect(response).to be_successful
  end

  it 'GET /jobs/new returns success' do
    get new_job_path
    expect(response).to be_successful
  end

  it 'POST /jobs creates a job' do
    expect {
      post jobs_path, params: { job: valid_attributes }
    }.to change(Job, :count).by(1)
  end

  it 'PATCH /jobs/:id updates a job' do
    job = Job.create!(valid_attributes.merge(user: user))
    patch job_path(job), params: { job: { title: 'Updated' } }
    expect(job.reload.title).to eq('Updated')
  end

  it 'DELETE /jobs/:id destroys a job' do
    job = Job.create!(valid_attributes.merge(user: user))
    expect {
      delete job_path(job)
    }.to change(Job, :count).by(-1)
  end
end
