Feature: 2.1 - The user accesses his profile page
  As an user
  I want have access to my profile page
  So that I can see my activity in the application

  Scenario: The user successfully accesses his profile
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com"' shares an idea with a reminder
    When I go to the profile page of "brandon@example.com"
    Then I should see "brandon@example.com"'s display name
    And I should see "has a new idea"
    And I should see "play the violin"
