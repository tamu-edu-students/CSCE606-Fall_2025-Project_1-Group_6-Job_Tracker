require 'rails_helper'

RSpec.describe 'New Job Back button', type: :system do
  before do
    driven_by :rack_test
  end

  let!(:user) { User.create!(email: 'u4@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'U4', phone: '+12345678904') }
  before { login_as(user, scope: :user) }

  it 'returns to dashboard when clicking Back on the new job page' do
    visit new_job_path
    expect(page).to have_current_path(new_job_path)
    click_link 'Back'
    expect(page).to have_current_path(dashboard_path)
  end
end
