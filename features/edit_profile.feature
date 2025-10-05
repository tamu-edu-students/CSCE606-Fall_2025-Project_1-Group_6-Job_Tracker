Feature: Edit Profile
  As a registered user
  I want to edit my profile information
  So that I can keep my account details accurate

  Background:
    Given I am a registered user
    And I am logged in

  Scenario: Successfully updating profile with valid information
    When I go to the Edit Profile page
    And I update my profile with valid information
    Then I should see "Your account has been updated successfully."

  Scenario: Updating profile with invalid email
    When I go to the Edit Profile page
    And I enter an invalid email
    Then I should see "must be a valid email address"

  Scenario: Updating profile without providing current password
    When I go to the Edit Profile page
    And I update profile details without current password
    Then I should see "Current password can't be blank"
