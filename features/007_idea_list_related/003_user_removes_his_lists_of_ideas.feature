Feature: 7.3 - The user can remove his lists of ideas
  As an user
  I want to remove my lists of ideas
  So that I can get rid of the ones I don't use anymore

  Scenario: The user successfully removes one of his lists of ideas
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has 1 idea list
    And I am on the idea lists page
    When I click on one of the delete links
    Then I should not see all of "brandon@example.com" idea lists
    
