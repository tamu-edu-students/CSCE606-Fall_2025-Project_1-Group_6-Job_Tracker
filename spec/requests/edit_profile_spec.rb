require 'rails_helper'

RSpec.describe "Edit Profile (Devise)", type: :request do
  let(:user) { create(:user, password: "Password@123") }

  before do
    sign_in user, scope: :user
  end

  describe "PATCH /users" do
    context "with valid parameters (happy path)" do
      it "updates the profile successfully" do
        patch user_registration_path, params: {
          user: {
            full_name: "Updated Name",
            phone: "9876543210",
            location: "College Station, TX",
            linkedin_url: "https://linkedin.com/in/newprofile",
            resume_url: "https://example.com/resume.pdf",
            current_password: "Password@123"
          }
        }

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Your account has been updated successfully.")
        user.reload
        expect(user.full_name).to eq("Updated Name")
        expect(user.phone).to eq("9876543210")
      end
    end

    context "with invalid parameters (sad path)" do
      it "does not update when current password is wrong" do
        patch user_registration_path, params: {
          user: {
            full_name: "Invalid Update",
            current_password: "wrongpass"
          }
        }

        expect(response.body).to include("Current password is invalid")
        user.reload
        expect(user.full_name).not_to eq("Invalid Update")
      end

      it "shows validation errors for invalid email" do
        patch user_registration_path, params: {
          user: {
            email: "invalid_email",
            current_password: "Password@123"
          }
        }

        expect(response.body).to include("Email is invalid")
      end
    end
  end
end
