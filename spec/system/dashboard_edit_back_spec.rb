require 'rails_helper'

RSpec.describe 'Dashboard edit/back behavior', type: :system do
  before do
    driven_by :rack_test
  end

  let!(:user) { User.create!(email: 'u3@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U3', phone: '+12345678903') }
  let!(:company) { Company.create!(name: 'DashCo', website: 'https://dashco.example') }
  let!(:job) { Job.create!(title: 'DashJob', user: user, company: company) }

  before { login_as(user, scope: :user) }

  it 'returns to dashboard when clicking Back on the edit page' do
    visit dashboard_path

    # Click the Edit link for the job — there may be multiple buttons, find by link text near the job title
    within(:xpath, "//tr[td[contains(., 'DashJob')]]") do
      click_link 'Edit'
    end

    expect(page).to have_current_path(edit_job_path(job))

    click_link 'Back'

    expect(page).to have_current_path(dashboard_path)
  end
end
