Feature: Cannot sign up with duplicate email
  Background:
    Given there is a user with:
      | email    | dup@example.com |
      | password | DupPass1!       |
      | full_name| Dup User        |
      | phone    | +12345678901    |

  Scenario: Signing up with same email fails
    Given I am on the sign up page
    When I sign up with:
      | Full name         | New User       |
      | Email             | dup@example.com|
      | Phone             | +12345678902   |
      | Password          | Another1!      |
      | Password confirm  | Another1!      |
    Then I should see "Email has already been taken" or "has already been taken"
