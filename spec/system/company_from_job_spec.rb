require 'rails_helper'

RSpec.describe 'Create company from job form', type: :system do
  before do
    driven_by :rack_test
  end

  let!(:user) { User.create!(email: 'u2@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U2', phone: '+12345678902') }

  before do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'Password1!'
    click_button 'Log in'
  end

  it 'creates a company from the job form and returns to the job form' do
    visit new_job_path

    expect(page).to have_current_path(new_job_path)

    # Click the Add New Company link which should include the return_to param
    click_link 'Add New Company'

    expect(page).to have_current_path(new_company_path(return_to: 'jobs_new'))

  fill_in 'Name', with: 'SystemCo'
  fill_in 'Website', with: 'https://systemco.example'
  click_button 'Create Company'

    # After creating, we should be back on the job form
    expect(page).to have_current_path(new_job_path)

  # The company select should include the newly created company
  expect(page).to have_select('Company')
  expect(find_field('Company').all('option').map(&:text)).to include('System Co')
  end

  it 'shows validation errors when creating a company with blank name and stays on companies/new' do
    visit new_company_path(return_to: 'jobs_new')
    within('.card') do
      fill_in 'Name', with: ''
      click_button 'Create Company'
      # On validation failure the form will re-render; ensure we see the validation errors
      expect(page).to have_content("can't be blank")
    end
  end
end
