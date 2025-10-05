require 'rails_helper'

RSpec.describe 'Job show back behavior', type: :system do
  before do
    driven_by :rack_test
  end

  let!(:user) { User.create!(email: 'u5@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U5', phone: '+12345678905') }
  let!(:company) { Company.create!(name: 'BackCo', website: 'https://backco.example') }
  let!(:job) { Job.create!(title: 'BackJob', user: user, company: company) }

  before { login_as(user, scope: :user) }

  it 'returns to dashboard when job was opened from dashboard and Back is clicked' do
    visit dashboard_path

    # Click the job title link in the dashboard table
    within(:xpath, "//tr[td[contains(., 'BackJob')]]") do
      click_link 'BackJob'
    end

  expect(page).to have_current_path(job_path(job, from: 'dashboard'))

    within('.card') do
      click_link 'Back'
    end

    expect(page).to have_current_path(dashboard_path)
  end
end
