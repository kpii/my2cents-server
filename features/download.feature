Feature: Download the client

  I want to download the client.
  Because.


  Scenario: Download the client
  
    When I go to the root page
    And I follow "Get the app"
    Then I should see "Android"
    And I should see "iPhone"
