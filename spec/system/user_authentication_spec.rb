# spec/system/user_authentication_spec.rb
require "rails_helper"

RSpec.describe "User authentication", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "allows a user to sign up successfully" do
    visit new_user_registration_path
    fill_in "Full name", with: "Capybara User"
    fill_in "Email", with: "capybara@example.com"
    fill_in "Phone", with: "+12345678901"
    fill_in "Password", with: "CapPass1!"
    fill_in "Password confirmation", with: "CapPass1!"
    click_button "Sign up"
    expect(page).to have_content("Welcome! You have signed up successfully.").or have_content("signed up successfully")
  end

  it "prevents duplicate email signups" do
    create(:user, email: "dupme@example.com")
    visit new_user_registration_path
    fill_in "Full name", with: "New Name"
    fill_in "Email", with: "dupme@example.com"
    fill_in "Phone", with: "+12345678902"
    fill_in "Password", with: "Another1!"
    fill_in "Password confirmation", with: "Another1!"
    click_button "Sign up"
    expect(page).to have_content("has already been taken")
  end

  it "allows login, remember me, and logout flows" do
    create(:user, email: "flowuser@example.com", password: "FlowPass1!", password_confirmation: "FlowPass1!")
    visit new_user_session_path
    fill_in "Email", with: "flowuser@example.com"
    fill_in "Password", with: "FlowPass1!"
    check "Remember me"
    click_button "Log in"
    expect(page).to have_content("Signed in successfully").or have_content("signed in successfully")
    click_link_or_button "Log out"
    expect(page).to have_content("Signed out successfully").or have_content("signed out")
  end

  it "requests a password reset" do
    create(:user, email: "pwreset@example.com")
    visit new_user_password_path
    fill_in "Email", with: "pwreset@example.com"
    click_button "Send me reset password instructions"
    expect(page).to have_content("You will receive an email with instructions")
  end
end
