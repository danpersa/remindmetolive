Feature: 3.1 - The user accesses the home page
  As an user
  I want to see the last activity of the people I follow
  So that I can be in touch with them
  
  Scenario: The user successfully accesses the home page 
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    |   Username      |   Email                |
    |   FirstUser     |   first@example.com    |
    |   SecondUser    |   second@example.com   |
    And "brandon@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    And "second@example.com" shares the same idea
    And "brandon@example.com" has and idea list of name "TheIdeaList"
    And "brandon@example.com" has a display name of "TheUser"
    And "first@example.com" follows "brandon@example.com"
    And "second@example.com" follows "brandon@example.com"
    And "brandon@example.com" follows "second@example.com"
    When I go to the home page
    Then I should see "TheUser"
    And I should see "TheIdeaList"
    And I should not see "FirstUser"
    And I should see "1 other person"
    And I should see "Followers (2)"
    And I should see "Following (1)"
    And I should see "1 idea"