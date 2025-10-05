require 'rails_helper'

RSpec.describe 'Job show back behavior', type: :system do
  before do
    driven_by :rack_test
  end

  let!(:user) { User.create!(email: 'u5@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U5', phone: '+12345678905') }
  let!(:company) { Company.create!(name: 'BackCo', website: 'https://backco.example') }
  let!(:job) { Job.create!(title: 'BackJob', user: user, company: company) }

  before do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'Password1!'
    click_button 'Log in'
  end

  it 'returns to jobs list when job was opened from jobs list and Back is clicked' do
    visit jobs_path

    # Click the job title link in the jobs table
    within('table#jobs-table') do
      click_link 'BackJob'
    end

    expect(page).to have_current_path(job_path(job))

    # Back from the show page should return to the jobs list
    click_link 'Back'
    expect(page).to have_current_path(jobs_path)
  end
end
