Feature: Job search
  As a signed-in user
  I want to filter jobs in the dashboard using the search bar

  Background:
    Given a user exists with email "search_user@example.com"
    And I am signed in as "search_user@example.com"
    And a company exists with name "SearchCo"
    And a job exists titled "FindMe" for company "SearchCo"
    And a job exists titled "Other" for company "SearchCo"

  Scenario: Search input is present on jobs list
    When I visit the jobs list
    Then I should see the search input
    And I should see a job titled "FindMe"
    And I should see a job titled "Other"
    Scenario: Search form submits and filters results (non-JS)
      Given a job exists titled "FindMe" for company "SearchCo"
      Given a job exists titled "Other" for company "SearchCo"
      When I visit the jobs list
      And I fill in the search input with "FindMe"
      And I press Search
      Then I should see a job titled "FindMe"
      And I should not see a job titled "Other"