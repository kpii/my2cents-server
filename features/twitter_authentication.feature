Feature: Authentication with Twitter

  In order to post comments as an authenticated user
  I want to sign in with Twitter


  Scenario: Login with Twitter, then log out and login again

    Given twitter would authenticate me

    When I go to "the root page"
    And I follow "Login with Twitter"
    Then I should see "Logged in as kpi_k2"

    When I follow "Log out"
    Then I should see "Login with Twitter"

    When I follow "Login with Twitter"
    Then I should see "Logged in as kpi_k2"


  Scenario: Authenticate, then come back in a new browser session

    Given twitter would authenticate me

    When I go to "the root page"
    And I follow "Login with Twitter"
    Then I should see "Logged in as kpi_k2"

    When I keep the permanent cookies and start a new browser session
    And I go to "the root page"
    Then I should see "Logged in as kpi_k2"


  Scenario: There is a transient failure getting the request token from twitter

    Given twitter would authenticate me
    But getting a request token from twitter fails twice

    When I go to "the root page"
    And I follow "Login with Twitter"
    Then I should see "Logged in as kpi_k2"


  Scenario: There is a transient failure getting the access token from twitter

    Given twitter would authenticate me
    But getting an access token from twitter fails twice

    When I go to "the root page"
    And I follow "Login with Twitter"
    Then I should see "Logged in as kpi_k2"


  Scenario: There is a permanent failure getting the request token from twitter

    Given twitter would authenticate me
    But getting a request token from twitter fails all the time

    When I go to "the root page"
    And I follow "Login with Twitter"
    Then I should see "Sorry, there seems to be an error with the Twitter API"
    And I should see "retry"


  Scenario: There is a permanent failure getting the access token from twitter

    Given twitter would authenticate me
    But getting an access token from twitter fails all the time

    When I go to "the root page"
    And I follow "Login with Twitter"
    Then I should see "Sorry, there seems to be an error with the Twitter API"
    And I should see "retry"
