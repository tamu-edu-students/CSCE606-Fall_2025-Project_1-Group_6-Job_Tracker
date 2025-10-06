# features/step_definitions/user_steps.rb
require 'capybara/dsl'
include Capybara::DSL

Given("the system has no user with email {string}") do |email|
  User.where(email: email).delete_all
end

Given("there is a user with:") do |table|
  attrs = table.rows_hash.symbolize_keys
  password = attrs.delete(:password) || "Password1!"
  attrs[:password] = password
  attrs[:password_confirmation] = password
  FactoryBot.create(:user, attrs)
end

Given("I am on the sign up page") do
  visit new_user_registration_path
  expect(page).to have_current_path(new_user_registration_path)
end

When("I sign up with:") do |table|
  attrs = table.rows_hash
  fill_in "Full name", with: attrs["Full name"]
  fill_in "Email", with: attrs["Email"]
  fill_in "Phone", with: attrs["Phone"]
  fill_in "Password", with: attrs["Password"]
  fill_in "Password confirmation", with: attrs["Password confirm"]
  click_button "Sign up"
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see {string} or {string}") do |a, b|
  expect(page).to have_content(a).or have_content(b)
end

Given("I go to the login page") do
  visit new_user_session_path
  expect(page).to have_current_path(new_user_session_path)
end

When("I sign in with email {string} and password {string}") do |email, password|
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Log in"
end

When("I sign in with email {string} and password {string} and check remember me") do |email, password|
  fill_in "Email", with: email
  fill_in "Password", with: password
  check "Remember me"
  click_button "Log in"
end

Then("I should still be signed in") do
  visit root_path
  expect(page).to have_content("Logout").or have_content("Sign out")
end

Given("I am signed in as {string}") do |email|
  user = User.find_by(email: email) || FactoryBot.create(:user, email: email, password: "Password1!", password_confirmation: "Password1!")
  login_as(user, scope: :user)
  visit root_path
  expect(page).to have_content("Logout").or have_content("Sign out")
end

When("I click {string}") do |link|
  click_link_or_button link
end

Given("I am on the forgot password page") do
  visit new_user_password_path
  expect(page).to have_current_path(new_user_password_path)
end

When("I request password reset for {string}") do |email|
  fill_in "Email", with: email
  click_button "Send me reset password instructions"
end
