Feature: Dashboard navigation
  As a signed-in user
  I want Back to return me to the dashboard after opening a job from there

  Background:
    Given a user exists with email "dash_user@example.com"
    And I am signed in as "dash_user@example.com"

  Scenario: Open job from jobs list and go back
    Given a job exists titled "BackJob" for company "DashCo"
    When I visit the jobs list
    And I click the job titled "BackJob"
    Then I should be on the job details page for "BackJob"
    When I click "Back"
    Then I should be on the jobs list
