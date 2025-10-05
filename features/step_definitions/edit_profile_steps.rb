Given("I am a registered user") do
  @user = User.create!(
    full_name: "John Doe",
    email: "john@example.com",
    phone: "+12345678901",
    password: "Password@123",
    password_confirmation: "Password@123"
  )
end

Given("I am logged in") do
  visit new_user_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: "Password@123"
  click_button "Log in"
end

When("I go to the Edit Profile page") do
  visit edit_user_registration_path
end

When("I update my profile with valid information") do
  fill_in "Full name", with: "Jane Doe"
  fill_in "Phone", with: "+19876543210"
  fill_in "Location", with: "Austin, TX"
  fill_in "Linkedin url", with: "https://linkedin.com/in/janedoe"
  fill_in "Resume url", with: "https://drive.google.com/resume.pdf"
  attach_file "Profile photo", Rails.root.join("spec/fixtures/files/sample.jpg")
  fill_in "Current password", with: "Password@123"
  click_button "Update"
end

When("I enter an invalid email") do
  fill_in "Email", with: "invalidemail"
  fill_in "Current password", with: "Password@123"
  click_button "Update"
end

When("I update profile details without current password") do
  fill_in "Full name", with: "New Name"
  click_button "Update"
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end
