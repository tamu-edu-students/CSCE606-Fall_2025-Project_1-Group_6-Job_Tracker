@companies
Feature: Manage Companies
  As a logged-in user
  I want to create or edit companies
  So that I can assign them to my job applications

  Background:
    Given I am logged in as a valid user
    And I am on the "New Company" page

  Scenario: Successfully create a company
    When I fill in "Name" with "SystemCo"
    And I fill in "Website" with "https://systemco.example"
    And I press "Create Company"
    Then I should see "Company created successfully"
    And I should be on the companies list page

  Scenario: Validation error on missing name
    When I fill in "Name" with ""
    And I press "Create Company"
    Then I should see "Name can't be blank"
