  let!(:job1) { Job.create!(title: 'Developer', company: company, user: user, status: 'applied') }
  let!(:job2) { Job.create!(title: 'Designer', company: company, user: user, status: 'interview') }

  describe 'GET #search' do
    it 'returns jobs matching the title' do
      get :search, params: { q: 'Developer' }, format: :js
      expect(assigns(:jobs)).to include(job1)
      expect(assigns(:jobs)).not_to include(job2)
    end

    it 'returns jobs matching the company name' do
      get :search, params: { q: 'TestCo' }, format: :js
      expect(assigns(:jobs)).to include(job1, job2)
    end

    it 'returns all jobs if query is blank' do
      get :search, params: { q: '' }, format: :js
      expect(assigns(:jobs)).to include(job1, job2)
    end

    it 'responds with JS format' do
      get :search, params: { q: 'Developer' }, format: :js
      expect(response.content_type).to eq 'text/javascript; charset=utf-8'
    end
  end
require 'rails_helper'

RSpec.describe JobsController, type: :controller do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:company) { Company.create!(name: 'TestCo', website: 'https://testco.com') }
  let(:valid_attributes) do
    { title: 'Developer', company_id: company.id, link: 'https://job.com', deadline: Date.today + 7, notes: 'Remote', status: 'applied' }
  end

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      Job.create!(valid_attributes.merge(user: user))
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      job = Job.create!(valid_attributes.merge(user: user))
      get :show, params: { id: job.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    it 'creates a new Job' do
      expect {
        post :create, params: { job: valid_attributes }
      }.to change(Job, :count).by(1)
    end
  end

  describe 'PATCH #update' do
    it 'updates the requested job' do
      job = Job.create!(valid_attributes.merge(user: user))
      patch :update, params: { id: job.id, job: { title: 'Updated' } }
      job.reload
      expect(job.title).to eq('Updated')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested job' do
      job = Job.create!(valid_attributes.merge(user: user))
      expect {
        delete :destroy, params: { id: job.id }
      }.to change(Job, :count).by(-1)
    end
  end
end
