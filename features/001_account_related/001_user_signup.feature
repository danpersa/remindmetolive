Feature: 1.1 - The user signes up
  As a guest
  I want to sign up for an account
  So that I can access the application
  
  Scenario: The guest successfully signes up
    And recaptcha is disabled
    And I am on the sign up page
    When I fill in the following:
     | Username                    | danix          |
     | Email                       | dan@yahoo.com  |
     | user_password               | password       |
     | Password confirmation       | password       |
    And I press "Create new account"
    Then I should see "Please follow the steps from the email we sent you to activate your account!"
    And I should see "Sign in"
    And I should have 1 user

  Scenario: The password has less than 6 chars
    Given recaptcha is enabled
    And I am on the sign up page
    When I fill in the following:
     | Username                    | danix          |
     | Email                       | dan@yahoo.com  |
     | user_password               | pad            |
     | Password confirmation       | pad            |
    And I press "Create new account"
    Then I should see "is too short"
    And I should see "Join remind me to live"
    And I should have 0 users