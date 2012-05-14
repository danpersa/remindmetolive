Feature: 1.3 - The user signs in
  As an user
  I want to sign in the application
  So that I can access my account and use all application features
  
  Scenario: The user successfully signs in
    Given an user exists with an email of "brandon@example.com"
    And "brandon@example.com"'s the account is activated
    And I go to the sign in page
    When I fill in "Email" with "brandon@example.com"
    And I fill in "Password" with "foobar" 
    And I press "Sign in"
    Then I should see "Remind me to"



