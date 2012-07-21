@android-104-compatibility
@no-txn
Feature: Support old android clients

  As a user who has installed a client that does not use the new scan API yet
  I want to see product information and post a comment


  Scenario: Implicitly create a product by accessing a legacy product URL

    Given my user agent is "Android my2cents [1.0.4]"
    And background workers are running
 
    And no product with gtin 0000000000010 exists
    And no product with gtin 0000000000011 exists
    And the id for the next generated product would be 333

    When I GET /products/0000000000010.json
    Then I should see json
    And json['product']['key'] should be "0000000000010-333"
    And json['product']['name'] should be "Unknown Product (0000000000010)"
    And json['product']['comments'] should be an empty array

    When I GET /products/0000000000011.json
    And I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"0000000000011","body":"I love it"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['comment']['body'] should be "I love it"
    And json['comment']['product']['key'] should be "0000000000011-334"
