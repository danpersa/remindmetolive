Feature: 3.3 - The user or guest accesses the contact page
  As an user or guest
  I want to contact the administrators of this application
  So that I can ask questions or congratulate them

  Scenario: The guest successfully accesses the contact page 
    Given I am a guest
    When I go to the contact page
    Then I should see "Contact"
    And I should see "Sign in"
    And I should see "Developed by Dan Persa"

  Scenario: The user successfully accesses the contact page 
    Given a logged user with email "brandon@example.com"
    When I go to the contact page
    Then I should see "Contact"
    And I should see "Sign out"
    And I should see "Developed by Dan Persa"