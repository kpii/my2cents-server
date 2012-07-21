Feature: Display comments and post a comment

  As a mobile app user
  I want to see other people's comments and post comments on my own
  So that I can engage in the dialog about products.


  Scenario: Display comments with product and user

    Given the following products exist
      |   id |          gtin | name  | image_url                  |
      | 4444 | 1234567809128 | Seife | http://example.com/pic.png |
    And the following comments exist
      |  id | product | user  | body        | created_at          |
      | 500 | Seife   | klaus | i like      | 2010-03-09 11:00:03 |

    When I GET /comments.json
    Then I should see json

    And json.first['comment']['id'] should be 500
    And json.first['comment']['product']['key'] should be "1234567809128-4444"
    And json.first['comment']['product']['image_url'] should be "http://example.com/pic.png"

    And json.first['comment']['user']['id'] should be the user id of "klaus"
    And json.first['comment']['user']['name'] should be "klaus"


  Scenario: Display comments, paginated

    Given 35 comments exist

    When I GET /comments.json
    Then I should see json
    And json.first['comment'] should not be nil
    And json.size should be 30

    When I GET /comments.json?page=2
    Then I should see json
    And json.first['comment'] should not be nil
    And json.size should be 5


  Scenario: Post a comment anonymously

    Given the following products exist
      |   id |          gtin | name  |
      | 4444 | 1234567809128 | Seife |

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"I love it"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['comment']['body'] should be "I love it"

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['comments'].first['body'] should be "I love it"
    And json['product']['comments'].first['user']['name'] should be "Anonymous"
    And json['product']['comments'].first['user']['profile_image_url'] should be "http://www.example.com/images/anonymous.png?4"


  Scenario: Post a comment with location (should not raise error)

    Given the following products exist
      |   id |          gtin | name  |
      | 4444 | 1234567809128 | Seife |

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"I love it",
    "latitude":"52.5416260957718","longitude":"13.3700770139694"}}
    """
    Then I should receive a 201 created response

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['comments'].first['body'] should be "I love it"


  Scenario: Authenticate and post a comment

    Given the following products exist
      |   id |          gtin | name             | image_url                            |
      | 4444 | 1234567809128 | Alpro Soja Milch | http://example.com/product_image.png |

    When I GET /login

    Then I should receive a redirect to "/oauth/authenticate" on twitter with oauth_token
    When I request and display that page to my user
    And twitter finally redirects me to "http://my2cents.mobi/oauth_callback"
    And I GET /oauth_callback?oauth_token=fake
 
    Then I should receive a "remember_token" cookie

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"I love it"}}
    """
    And I include the "remember_token" cookie

    Then I should receive a 201 created response
    And I should see json
    And json['comment']['body'] should be "I love it"
    And json['comment']['user']['name'] should be "kpi_k2"
    And json['comment']['user']['profile_image_url'] should be "http://a3.twimg.com/profile_images/123/123_normal.jpg"
    And my twitter status should not get updated

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['comments'].first['body'] should be "I love it"
    And json['product']['comments'].first['user']['name'] should be "kpi_k2"
    And json['product']['comments'].first['user']['profile_image_url'] should be "http://a3.twimg.com/profile_images/123/123_normal.jpg"
    And json['product']['comments'].first['user'] should only include "id, name, profile_image_url"

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"I love it"},"publish_to_twitter":"0"}
    """
    Then I should receive a 201 created response
    Then my twitter status should not get updated

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"I love it"},"publish_to_twitter":"1"}
    """
    Then I should receive a 201 created response
    Then my twitter status should get updated

    When I GET /comments.json
    Then I should see json
    And json.first['comment']['body'] should be "I love it"
    And json.first['comment']['user']['profile_image_url'] should be "http://a3.twimg.com/profile_images/123/123_normal.jpg"
    And json.first['comment']['product']['key'] should be "1234567809128-4444"
    And json.first['comment']['product']['name'] should be "Alpro Soja Milch"
    And json.first['comment']['product']['image_url'] should be "http://example.com/product_image.png"

