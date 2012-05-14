Feature: 1.11 - The user deletes his account
  As an user
  I want to delete my account
  So that if I don't want to use the application, all the information stored in there is deleted

Scenario: The user successfully deletes his account
    Given a logged user with email "brandon@example.com"
    And I am on the edit profile page of "brandon@example.com"
    When I follow "Delete your account" 
    Then I should be on the home page
    And I should see "Your account was successfully deleted!"

Scenario: The user successfully donates his public shared ideas to the community
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    | Username          | Email              |
    | FirstUser     | first@example.com  |
    | SecondUser    | second@example.com |
    And "brandon@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    And "second@example.com" shares the same idea
    And I am on the edit profile page of "brandon@example.com"
    And I follow "Delete your account"
    When I go to the profile page of "community@remindmetolive.com"
    Then I should see "1 idea"