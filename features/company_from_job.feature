Feature: Create company from job form
  As a user creating a job
  I want to be able to add a new company and return to the job form

  Background:
    Given a user exists with email "company_user@example.com"
    And I am signed in as "company_user@example.com"

  Scenario: Create company from job form and return
    When I visit the new job page
    And I click the Add New Company link
    Then I should be on the new company page
    When I fill in the new company form with name "NewCo" and website "https://newco.example"
    And I submit the company form
    Then I should be back on the new job page