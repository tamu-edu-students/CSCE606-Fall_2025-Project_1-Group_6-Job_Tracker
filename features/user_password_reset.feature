Feature: Password reset (forgot password)
  Background:
    Given there is a user with:
      | email    | reset_user@example.com |
      | password | ResetPass1!            |
      | full_name| Reset User             |
      | phone    | +12345678901           |

  Scenario: Request password reset with existing email (happy)
    Given I am on the forgot password page
    When I request password reset for "reset_user@example.com"
    Then I should see "You will receive an email with instructions"

  Scenario: Request password reset with non-existing email (sad)
    Given I am on the forgot password page
    When I request password reset for "notexist@example.com"
    Then I should see "Email not found" or "not found"
