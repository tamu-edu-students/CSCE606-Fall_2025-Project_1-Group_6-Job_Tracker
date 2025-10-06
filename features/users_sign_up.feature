Feature: User sign up
  As a prospective user
  I want to register an account
  So that I can sign in and use the application

  Background:
    Given the system has no user with email "existing@example.com"

  Scenario: Successful sign up (happy path)
    Given I am on the sign up page
    When I sign up with:
      | Full name         | Test User         |
      | Email             | test@example.com  |
      | Phone             | +12345678901      |
      | Password          | Passw0rd!         |
      | Password confirm  | Passw0rd!         |
    Then I should see "Welcome! You have signed up successfully."

  Scenario: Sign up fails when password is too weak (sad path)
    Given I am on the sign up page
    When I sign up with:
      | Full name         | Test Weak         |
      | Email             | weak@example.com  |
      | Phone             | +12345678901      |
      | Password          | weakpass          |
      | Password confirm  | weakpass          |
    Then I should see "must include at least"
    And I should see "Password must be at least 8 characters long" or "is too short"
