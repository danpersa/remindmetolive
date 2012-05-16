Feature: 7.1 - The user can create lists of ideas
  As an user
  I want to create lists where to put my ideas
  So that I can be able to better organize my ideas

  @javascript
  Scenario: The user successfully creates a list for ideas (javascript)
    Given a logged user with email "brandon@example.com"
    And I am on the idea lists page
    And I follow "New list"
    When I fill in "Name" with "The Bucket List"
    And I press "Create List Of Ideas"
    Then I should see "Idea list successfully created"
    And I should see "The Bucket List"

  Scenario: The user successfully creates a list for ideas
    Given a logged user with email "brandon@example.com"
    And I am on the idea lists page
    And I follow "New list"
    When I fill in "Name" with "The Bucket List"
    And I press "Create"
    Then I should see "Idea list successfully created"
    And I should see "The Bucket List"