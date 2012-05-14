Feature: 2.6 - The user accesses the list of users that follow an user
  As an user
  I want to see the list of users that that follow an user
  So that I can see the people that thinks my (or another user's) ideas matters

  Scenario: The user successfully accesses the list of users that follow another user
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    |   Username      |   Email                |
    |   FirstUser     |   first@example.com    |
    |   SecondUser    |   second@example.com   |
    And "first@example.com" follows "second@example.com"
    When I go to the followers page of "second@example.com"
    Then I should see "FirstUser"
