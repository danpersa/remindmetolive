Feature: 1.6 - The user modifies public his profile
  As an user
  I want to set a public profile
  So that other users can see the information I want about me

  Scenario: The user successfully modifies his public profile
    Given a logged user with email "brandon@example.com"
    When I go to the edit public profile page of "brandon@example.com"
    And I fill in the following:
     | Name        | The User             |
     | Email       | user@yahoo.com       |
     | Location    | Bucharest            |
     | Website     | http://remindme.com  |
    And I press "Update Public Profile"
    Then I should see "Profile successfully updated"
    And "brandon@example.com"'s display name should be "The User"
