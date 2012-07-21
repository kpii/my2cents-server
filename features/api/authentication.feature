Feature: Authenticate through the API

  As a mobile app user
  I want to authenticate
  So that I can interact with my2cents using my identity


  Scenario: Authenticate with twitter, success
    
    Given my user agent is "Android my2cents RC2 rev424"
    And twitter would allow me access
    
    When I go to /login
    Then I should be on /auth/success


  Scenario: Authentication with twitter, failure

    Given my user agent is "Android my2cents"
    And twitter would not allow me access
    
    When I go to /login
    Then I should be on /auth/failure


