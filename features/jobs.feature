Feature: Job management
  In order to manage my applications
  As a signed-in user
  I want to create, view, edit and delete job applications

  Background:
    Given a user exists with email "cuke_user@example.com"
    And I am signed in as "cuke_user@example.com"

  Scenario: Create a job
    Given a company exists with name "CukeCo"
    When I visit the new job page
    And I fill in the new job form with title "CukeJob", company "CukeCo"
    And I submit the job form
    Then I should see a job titled "CukeJob" on the jobs list

  Scenario: Edit a job
    Given a company exists with name "EditCo"
    And a job exists titled "OldTitle" for company "EditCo"
    When I visit the jobs list
    And I click Edit for the job titled "OldTitle"
    And I change the job title to "NewTitle"
    And I submit the job form
    Then I should see a job titled "NewTitle" on the jobs list

  Scenario: Delete a job
    Given a company exists with name "DelCo"
    And a job exists titled "ToDelete" for company "DelCo"
    When I visit the jobs list
    And I delete the job titled "ToDelete"
    Then I should not see a job titled "ToDelete" on the jobs list
