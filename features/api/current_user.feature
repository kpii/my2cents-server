Feature: Return information about current user

  As an app
  I want to retrieve name and avatar of the current user
  So that I can show it to my user, e.g. to confirm that login has worked


  Scenario: Get information about anonymous user

    Given I include the cookie "client_token" with value "abcdef123456" in every request

    When I GET /me.json
    Then I should see json
    And json['me']['name'] should be "Anonymous"
    And json['me']['profile_image_url'] should be "http://www.example.com/images/anonymous.png?4"


  Scenario: Get information about registered user

    Given I include the cookie "client_token" with value "abcdef123456" in every request
    And the following users exist
    | name  | profile_image_url           | twitter_access_token |
    | Franz | http://s3.aws.com/franz.png | secret               |
    And the following client_tokens exist
    | user  | token        |
    | Franz | abcdef123456 |

    When I GET /me.json
    Then I should see json
    And json['me']['name'] should be "Franz"
    And json['me']['profile_image_url'] should be "http://s3.aws.com/franz.png"
    But json['me']['twitter_access_token'] should be nil

  
