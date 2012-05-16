Feature: 7.2 - The user can see all his lists of ideas
  As an user
  I want to see all the lists for my ideas
  So that I can be able to better organize them

  Scenario: The user successfully sees all his lists for ideas
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has 5 idea lists
    When I go to the idea lists page
    Then I should see all of "brandon@example.com" idea lists