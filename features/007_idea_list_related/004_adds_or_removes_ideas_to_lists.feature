Feature: 7.4 - The user can add and remove ideas to his lists
  As an user
  I want to add or remove ideas from my lists of ideas
  So that I can better organize my ideas

  Scenario: The user successfully adds an idea to a list
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has 1 idea list
    And "brandon@example.com" shares 1 idea
    And I am on the "brandon@example.com"'s idea page
    When I fill in "idea_idea_list_tokens" with the idea list name
    And I press "Update lists"
    Then I should see all of "brandon@example.com" idea lists
  
  @todo
  Scenario: The user successfully removes an idea to a list