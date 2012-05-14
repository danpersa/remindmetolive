Feature: 1.8 - The application uses CAPTCHA when registering an user
  As an application
  I don't want to let bots create accounts in the application
  So that the users from the application to be real people

  @javascript
  Scenario: The application successfully uses CAPTCHA
    Given recaptcha is enabled
    When I go to the sign up page
    Then I should see "Type the two words"