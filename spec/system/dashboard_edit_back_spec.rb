require 'rails_helper'

RSpec.describe 'Dashboard edit/back behavior', type: :system do
  before do
    driven_by :rack_test
  end

  let!(:user) { User.create!(email: 'u3@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U3', phone: '+12345678903') }
  let!(:company) { Company.create!(name: 'DashCo', website: 'https://dashco.example') }
  let!(:job) { Job.create!(title: 'DashJob', user: user, company: company) }

  before { login_as(user, scope: :user) }

  it 'returns to jobs list when clicking Back on the edit page' do
    visit jobs_path

    # Click the Edit link for the job in the jobs table
    within('table#jobs-table') do
      within(:xpath, ".//tr[td[contains(., 'DashJob')]]") do
        click_link 'Edit'
      end
    end

    expect(page).to have_current_path(edit_job_path(job))

    # Click the Back link in the form to return to jobs list (avoid other Back links)
    within('.form-panel') do
      click_link 'Back'
    end
    expect(page).to have_current_path(jobs_path)
  end
end
