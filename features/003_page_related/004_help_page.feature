Feature: 3.4 - The user or guest accesses the help page
  As an user or guest
  I want to get help starting up with the application
  - And tips to use the application
  - And get answers to the commons questions about the application
  So that I can use all features of the application

  Scenario: The guest successfully accesses the help page 
    Given I am a guest
    When I go to the help page
    Then I should see "Help"
    And I should see "Sign in"
    And I should see "This is the help page!"

  Scenario: The user successfully accesses the help page 
    Given a logged user with email "brandon@example.com"
    When I go to the help page
    Then I should see "Help"
    And I should see "Sign out"
    And I should see "This is the help page!"