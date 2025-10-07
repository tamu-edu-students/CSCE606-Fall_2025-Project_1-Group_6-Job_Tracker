# frozen_string_literal: true

# ================================
# Steps for Export Jobs feature
# ================================

When('I am in the Job List page') do
  visit jobs_path
  # Confirm we actually reached the page
  expect(page).to have_content('Job List').or have_content('My Job Applications')
end

When('I click the {string} button') do |button_text|
  # Allow flexibility between "Export Jobs" and "Export Jobs (CSV)"
  candidates = [button_text, button_text.gsub('(CSV)', '').strip]
  found = candidates.find { |t| page.has_button?(t, wait: 1) || page.has_link?(t, wait: 1) }

  if found
    click_link_or_button(found)
  else
    raise Capybara::ElementNotFound, "❌ Could not find button or link '#{button_text}'"
  end
end

Then('I should receive a CSV file named {string}') do |filename|
  headers = page.response_headers

  expect(headers['Content-Type']).to include('text/csv'),
    "Expected Content-Type to be text/csv, got #{headers['Content-Type']}"

  expect(headers['Content-Disposition']).to include("filename=\"#{filename}\""),
    "Expected filename to be #{filename}, got #{headers['Content-Disposition']}"
end

Then('the file should contain {string}') do |expected_line|
  # Simple substring match for expected CSV content
  expect(page.body).to include(expected_line),
    "Expected CSV to contain '#{expected_line}', but got:\n#{page.body.truncate(200)}"
end
