# frozen_string_literal: true

require 'capybara/rails'

# --------------------------
# GENERAL LOGIN + NAVIGATION
# --------------------------

Given('I am logged in as a valid user') do
  @user = User.create!(
    email: 'cucumber_user@example.com',
    password: 'Password1!',
    password_confirmation: 'Password1!',
    full_name: 'Cucumber User',
    phone: '+1234567890'
  )
  login_as(@user, scope: :user)
end

Given('I am on the {string} page') do |page_name|
  path = case page_name.downcase
  when 'my job applications' then jobs_path
  when 'new company' then new_company_path
  when 'reminders' then reminders_path
  when 'dashboard' then dashboard_path
  else
           raise "Unknown page: #{page_name}"
  end
  visit path
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press {string}') do |button|
  click_button button
end

Then('I should be on the companies list page') do
  expect(page).to have_current_path(companies_path)
end

When('I set the hidden field {string} to {string}') do |field, value|
  find("input[name='#{field}']", visible: false).set(value)
end

Then('I should be redirected to the new job form') do
  expect(page).to have_current_path(new_job_path)
end

# --------------------------
# JOBS / IMPORT / EXPORT
# --------------------------

Given('I have the following jobs:') do |table|
  table.hashes.each do |row|
    company = Company.find_or_create_by!(name: row['company'], website: "https://#{row['company'].downcase}.com")
    Job.create!(
      title: row['title'],
      company: company,
      status: row['status'],
      deadline: row['deadline'],
      user: @user
    )
  end
end

When('I click the {string} button') do |button_text|
  click_link_or_button(button_text.gsub('(CSV)', '').strip)
end

Then('I should receive a CSV file named {string}') do |filename|
  expect(page.response_headers['Content-Disposition']).to include("filename=\"#{filename}\"")
end

Then('the file should contain {string}') do |content|
  expect(page.body).to include(content)
end

Given('another user exists with a job titled {string}') do |title|
  other_user = User.create!(
    email: 'other@example.com',
    password: 'Password1!',
    password_confirmation: 'Password1!',
    full_name: 'Other User',
    phone: '+12345678901' # ✅ Added valid phone
  )
  company = Company.create!(name: 'OtherCo', website: 'https://otherco.example')
  Job.create!(title: title, user: other_user, company: company, status: 'to_apply', deadline: 1.week.from_now)
end

Then('I should not see {string} in the exported CSV') do |text|
  expect(page.body).not_to include(text)
end

When('I attach the file {string} to the {string} form') do |file_path, _form_label|
  full_path = Rails.root.join(file_path)
  attach_file('file', full_path)
end

Then('I should see {string} and {string} in the job list') do |job1, job2|
  expect(page).to have_content(job1)
  expect(page).to have_content(job2)
end

Given('I already have a job titled {string} at {string}') do |title, company_name|
  company = Company.find_or_create_by!(name: company_name, website: "https://#{company_name.downcase}.example")
  Job.create!(
    title: title,
    user: @user,
    company: company,
    status: 'to_apply',
    deadline: 1.week.from_now
  )
end

Given('I have a job titled {string} at {string}') do |title, company_name|
  step "I already have a job titled \"#{title}\" at \"#{company_name}\""
end

# --------------------------
# REMINDERS
# --------------------------

When('I visit the reminders page') do
  visit reminders_path
end

When('I add a reminder of type {string} for {string} with time {string}') do |type, job_title, time|
  job = Job.find_by!(title: job_title, user: @user)
  visit new_reminder_path
  select job.title, from: 'reminder_job_id'
  select type.capitalize, from: 'reminder_reminder_type'
  fill_in 'reminder_reminder_time', with: time
  click_button 'Create Reminder'
end

Given('I already have a deadline reminder for {string}') do |job_title|
  job = Job.find_by!(title: job_title)
  Reminder.create!(
    user: @user,
    job: job,
    reminder_type: 'deadline',
    reminder_time: 1.day.from_now,
    disabled: false
  )
end

When('I add an {string} reminder for {string} with time {string}') do |type, job_title, time|
  step "I add a reminder of type \"#{type}\" for \"#{job_title}\" with time \"#{time}\""
end

When('I add a {string} reminder for {string} with time {string}') do |type, job_title, time|
  step "I add a reminder of type \"#{type}\" for \"#{job_title}\" with time \"#{time}\""
end

When('I add another {string} reminder for {string}') do |type, job_title|
  job = Job.find_by!(title: job_title, user: @user)
  visit new_reminder_path
  select type.capitalize, from: 'Type'
  select job.title, from: 'Job'
  click_button 'Create Reminder'
end

Given('I have a job titled {string} at {string} with status {string}') do |title, company_name, status|
  company = Company.find_or_create_by!(name: company_name, website: "https://#{company_name.downcase}.example")
  Job.create!(
    title: title,
    user: @user,
    company: company,
    status: status,
    deadline: 1.week.from_now
  )
end

Given('I add an {string} reminder for {string}') do |type, job_title|
  job = Job.find_by!(title: job_title, user: @user)
  Reminder.create!(
    user: @user,
    job: job,
    reminder_type: type,
    reminder_time: 1.day.from_now,
    disabled: false
  )
end

When('I am in the Job List page') do
  visit jobs_path
  expect(page).to have_content('Job List').or have_content('My Job Applications')
end
