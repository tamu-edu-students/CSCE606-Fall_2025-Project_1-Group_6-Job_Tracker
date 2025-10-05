Given('a user exists with email {string}') do |email|
  User.create!(email: email, password: 'Password1!', password_confirmation: 'Password1!', full_name: 'Cuke', phone: '+10000000000')
end

Given('I am signed in as {string}') do |email|
  user = User.find_by(email: email)
  visit new_user_session_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'Password1!'
  click_button 'Log in'
end

Given('a company exists with name {string}') do |name|
  Company.create!(name: name, website: "https://#{name.downcase}.example")
end

Given('a job exists titled {string} for company {string}') do |title, company_name|
  user = User.first || User.create!(email: 'tmp@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'Tmp', phone: '+10000000001')
  company = Company.find_by(name: company_name) || Company.create!(name: company_name, website: "https://#{company_name.downcase}.example")
  Job.create!(title: title, user: user, company: company)
end

When('I visit the new job page') do
  visit new_job_path
end

When('I fill in the new job form with title {string}, company {string}') do |title, company_name|
  select company_name, from: 'job[company_id]'
  fill_in 'job[title]', with: title
end

When('I submit the job form') do
  # target the job form specifically (new_job or edit_job) to avoid ambiguous matches
  # prefer the form that contains the job title field to avoid ambiguous matches
  if has_selector?('form input[name="job[title]"]')
    within(:xpath, "//form[.//input[@name='job[title]']]") do
      first('input[type="submit"], button[type="submit"]').click
    end
  elsif has_selector?('form#new_job')
    within('form#new_job') { first('input[type="submit"], button[type="submit"]').click }
  elsif has_selector?('form#edit_job')
    within('form#edit_job') { first('input[type="submit"], button[type="submit"]').click }
  else
    within('form') { first('input[type="submit"], button[type="submit"]').click }
  end
end

Then('I should see a job titled {string} on the jobs list') do |title|
  visit jobs_path
  expect(page).to have_content(title)
end

# When('I visit the jobs list') is defined later (avoid duplicate definition)

When('I click Edit for the job titled {string}') do |title|
  within(:xpath, "//tr[td[contains(., '#{title}')]]") do
    click_link 'Edit'
  end
end

When('I change the job title to {string}') do |new_title|
  fill_in 'job[title]', with: new_title
end

When('I delete the job titled {string}') do |title|
  within(:xpath, "//tr[td[contains(., '#{title}')]]") do
    # button_to may render input or button; try both
    if has_selector?('input[type="submit"][value="Delete"]')
      find('input[type="submit"][value="Delete"]').click
    elsif has_selector?('button', text: 'Delete')
      find('button', text: 'Delete').click
    else
      # fallback to link
      click_link 'Delete'
    end
  end
end

Then('I should not see a job titled {string} on the jobs list') do |title|
  visit jobs_path
  expect(page).not_to have_content(title)
end

When('I click the Add New Company link') do
  click_link 'Add New Company'
end

Then('I should be on the new company page') do
  # ignore query params like return_to
  expect(URI.parse(page.current_url).path).to eq(new_company_path)
end

When('I fill in the new company form with name {string} and website {string}') do |name, website|
  fill_in 'company[name]', with: name
  fill_in 'company[website]', with: website
end

When('I submit the company form') do
  click_button 'Create Company'
end

Then('I should be back on the new job page') do
  expect(URI.parse(page.current_url).path).to eq(new_job_path)
end

When('I visit the dashboard') do
  visit dashboard_path
end

When('I visit the dashboard with query {string}') do |q|
  visit dashboard_path(q: q)
end

When('I visit the jobs list') do
  visit jobs_path
end

When('I visit the jobs list with query {string}') do |q|
  visit jobs_path(q: q)
end

When('I click the job titled {string}') do |title|
  within(:xpath, "//tr[td[contains(., '#{title}')]]") do
    click_link title
  end
end

Then('I should be on the job details page for {string}') do |title|
  job = Job.find_by(title: title)
  expect(URI.parse(page.current_url).path).to eq(job_path(job))
end

When('I click {string}') do |text|
  click_link text
end

When('I fill in the search input with {string}') do |query|
  # the dashboard search uses data-job-search-target or placeholder
  if has_selector?('input[data-job-search-target="input"]')
    find('input[data-job-search-target="input"]').set(query)
  else
    fill_in 'Search jobs by title or company...', with: query
  end
end

When('I press Search') do
  click_button 'Search'
end

Then('I should see a job titled {string}') do |title|
  expect(page).to have_content(title)
end

Then('I should not see a job titled {string}') do |title|
  expect(page).not_to have_content(title)
end

Then('I should be on the dashboard') do
  expect(URI.parse(page.current_url).path).to eq(dashboard_path)
end

Then('I should be on the jobs list') do
  expect(URI.parse(page.current_url).path).to eq(jobs_path)
end

Then('I should see the search input') do
  expect(page).to have_selector('input[data-job-search-target="input"]')
end
