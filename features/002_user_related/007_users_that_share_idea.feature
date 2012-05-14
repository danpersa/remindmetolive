Feature: 2.7 - The user accesses the list of users that share the same idea
  As an user
  I want to see all the users that shares an idea
  So that I can find interesting people to follow

  Scenario: The user successfully accesses the list of users that share the same idea
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    |   Username      |   Email               |
    |   FirstUser     |   first@example.com   |
    |   SecondUser    |   second@example.com  |
    And "brandon@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    And "second@example.com" shares the same idea
    When I go to the shared idea page
    Then I should see "FirstUser"
    And I should see "SecondUser"