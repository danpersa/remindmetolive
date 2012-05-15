Feature: 3.2 - The guest accesses the home page
  As a guest
  I want to find out why this application makes my life better
  So that I can start using the application

  Scenario: The guest successfully accesses home page 
    Given I am a guest
    When I go to the home page
    Then I should see "Sign Up Now"
    And I should see "Sign in"
    And I should see "make your life better"