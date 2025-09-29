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
