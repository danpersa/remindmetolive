Feature: 3.6 - The user or guest accesses the about page
  As an user or guest
  I want to find out information about the application and the team that created it and administrates it
  So that to know who made such an impressing application

  
  Scenario: The guest successfully accesses the about page 
    Given I am a guest
    When I go to the about page
    Then I should see "About"
    And I should see "Sign in"
    And I should see "Dan Persa is a passionate Java and Ruby developer"

  Scenario: The user successfully accesses the about page 
    Given a logged user with email "brandon@example.com"
    When I go to the about page
    Then I should see "About"
    And I should see "Sign out"
    And I should see "Dan Persa is a passionate Java and Ruby developer"