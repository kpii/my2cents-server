Feature: Rating through the API

  As a mobile app user
  I want to quickly rate a product
  So that I can give feedback without typing.


  Scenario: Retrieve rating info, add rating, remove rating

    Given the following products exist
    |   id |          gtin |
    | 4444 | 1234567809128 |

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['rating']['likes'] should be 0
    And json['product']['rating']['dislikes'] should be 0
    And json['product']['rating']['me'] should be nil

    When I PUT /products/1234567809128-4444/rating.json with content_type application/json
    """
    {"rating":{"value":"like"}}
    """
    Then I should receive a 200 OK response
    And I should see json
    And json['rating']['me'] should be "like"
    And json['rating']['likes'] should be 1
    And json['rating']['dislikes'] should be 0

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['rating']['likes'] should be 1
    And json['product']['rating']['dislikes'] should be 0
    And json['product']['rating']['me'] should be "like"

    When I PUT /products/1234567809128-4444/rating.json with content_type application/json
    """
    {"rating":{"value":null}}
    """
    Then I should receive a 200 OK response
    And I should see json
    And json['rating']['me'] should be nil
    And json['rating']['likes'] should be 0
    And json['rating']['dislikes'] should be 0

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['rating']['likes'] should be 0
    And json['product']['rating']['dislikes'] should be 0
    And json['product']['rating']['me'] should be nil
