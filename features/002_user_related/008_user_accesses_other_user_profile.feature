Feature: 2.8 - The user accesses another user's profile page
  As an user
  I want have access to another user's profile pages
  So that I can see their activity in the application
  And I can inspire from their ideas

  Scenario: The user successfully accesses another user's profile
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    |  Username      |   Email                 |
    |  AnotherUser   |   another@example.com   |
    And "another@example.com"' shares an idea with a reminder
    When I go to the profile page of "another@example.com"
    Then I should see "another@example.com"'s display name
    And I should see "play the violin"
    And I should see "Remind me too"

  Scenario: The user does not see the 'Remind me too' button for the ideas that he already shares
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    |   Username      |   Email                 |
    |   AnotherUser   |   another@example.com   |
    And "brandon@example.com" shares 1 idea
    And "another@example.com" shares the same idea
    When I go to the profile page of "another@example.com"
    Then I should see "another@example.com"'s display name
    And I should see "play the violin"
    And I should not see "Remind me too"