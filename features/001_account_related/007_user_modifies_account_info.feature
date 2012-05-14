Feature: 1.6 - The user modifies his profile
  As an user
  I want to change my profile details
  So that I can use my new email, username or picture

  Scenario: The user successfully modifies his profile
    Given a logged user with email "brandon@example.com"
    When I go to the edit profile page of "brandon@example.com"
    And I fill in the following:
     | Username    | Nicky                |
     | Email       | nicky@yahoo.com      |
    And I press "Update"
    Then I should see "Profile updated."
    And "nicky@yahoo.com"'s username should be "Nicky"
