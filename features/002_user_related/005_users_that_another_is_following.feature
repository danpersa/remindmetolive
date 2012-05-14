Feature: 2.5 - The user accesses the list of users that another user is following
  As an user
  I want to see the list of users that another user is following
  So that I can see whose ideas are important for that user

  Scenario: The user successfully accesses the list of users that another user is following
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    |   Username      |   Email               |
    |   FirstUser     |   first@example.com   |
    |   SecondUser    |   second@example.com  |
    And "first@example.com" follows "second@example.com"
    When I go to the following page of "first@example.com"
    Then I should see "SecondUser"
