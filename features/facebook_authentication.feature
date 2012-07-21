Feature: Authentication with Facebook

  In order to post comments as an authenticated user
  I want to sign in with Facebook


  Scenario: Login with Facebook and post a comment

    Given the following products exist
    | name      |
    | Club Mate |
    And facebook authenticates me with auth_token "foobar"
    And the facebook api returns user name "Hans" for auth_token "foobar"

    When I go to "the root page"
    Then I should see "Login with Facebook"
    And I should see "Login with Twitter"

    When I follow "Login with Facebook"
    Then I should see "Logged in as Gonzo Gogo"
    But I should not see "Login with Facebook"
    And I should not see "Login with Twitter"

    When I go to the product page of "Club Mate"
    Then I should not see "Publish comment on Twitter"

    When I fill in "comment_body" with "Comment from Gonzo"
    And I press "Create"
    And I follow "Gonzo Gogo"
    Then I should see "Comment from Gonzo"

    When I follow "Log out"
    Then I should see "Login with Facebook"

    When I follow "Login with Facebook"
    And I follow "Gonzo Gogo"
    Then I should see "Comment from Gonzo"
