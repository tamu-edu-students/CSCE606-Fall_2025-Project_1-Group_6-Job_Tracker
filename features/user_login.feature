Feature: User sign in / remember me / logout
  Background:
    Given there is a user with:
      | email    | login_user@example.com |
      | password | StrongPass1!           |
      | full_name| Login User             |
      | phone    | +12345678901           |

  Scenario: Successful login (happy path)
    Given I go to the login page
    When I sign in with email "login_user@example.com" and password "StrongPass1!"
    Then I should see "Signed in successfully."

  Scenario: Login with Remember me checked persists session between visits
    Given I go to the login page
    When I sign in with email "login_user@example.com" and password "StrongPass1!" and check remember me
    Then I should see "Signed in successfully."
    When I visit the root path
    Then I should still be signed in

  Scenario: Logout
    Given I am signed in as "login_user@example.com"
    When I click "Logout"
    Then I should see "Signed out successfully."
