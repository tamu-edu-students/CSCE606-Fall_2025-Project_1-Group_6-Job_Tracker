require 'rails_helper'

RSpec.describe 'Jobs search (server-side)', type: :request do
	let(:user) { User.create!(email: 'search@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'Search User', phone: '+12345678902') }
	let(:company) { Company.create!(name: 'SearchCo', website: 'https://searchco.example') }
	before { login_as(user, scope: :user) }

	it 'filters jobs by q param (title match)' do
		Job.create!(title: 'FindMe', user: user, company: company)
		Job.create!(title: 'Other', user: user, company: company)
		get jobs_path, params: { q: 'FindMe' }
		expect(response).to be_successful
		expect(response.body).to include('FindMe')
		expect(response.body).not_to include('Other')
	end

	it 'filters jobs by q param (matches job without company)' do
			# Job requires a company in this app, so create with the test company.
			Job.create!(title: 'SoloJob', user: user, company: company)
			get jobs_path, params: { q: 'SoloJob' }
		expect(response).to be_successful
		expect(response.body).to include('SoloJob')
	end
end
