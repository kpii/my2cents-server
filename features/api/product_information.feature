Feature: Get product information

  As a mobile app user
  I want to receive product information
  So that I get to know more and see other people's comments.


  Scenario: Product information with comments and user

    Given the following products exist
      |   id |          gtin | name  | image_url                  |
      | 4444 | 1234567809128 | Seife | http://example.com/pic.jpg |
    And the following comments exist
      |  id | product | user  | body        | created_at          |
      | 500 | Seife   | klaus | i like      | 2010-03-09 11:00:03 |
      | 501 | Seife   | hugo  | i dont like | 2010-03-10 12:00:05 |

    When I GET /products/1234567809128-4444.json
    Then I should see json

    And json['product']['key'] should be "1234567809128-4444"
    And json['product']['name'] should be "Seife"
    And json['product']['image_url'] should be "http://example.com/pic.jpg"

    And json['product']['comments'] should contain 2 elements
    And json['product']['comments'][0]['id'] should be 501
    And json['product']['comments'][0]['user']['id'] should be the user id of "hugo"
    And json['product']['comments'][0]['user']['name'] should be "hugo"
    And json['product']['comments'][0]['user'] should not contain a 'facebook_auth_token' item


  Scenario: Product information with affiliates, and deprecated affiliate_links

    Given a product "1234567809128-4444" named "Winnie the Pooh" from AmazonUsResponse
    And a product "1234567809129-55555" named "A Yoghurt" from CodecheckResponse
    And a product "1234567809130-66666" named "Another Yoghurt" from AffiliNetResponse
    
    When I GET /products/1234567809128-4444.json
    Then I should see json

    And json['product']['affiliates'] should contain 1 element
    And json['product']['affiliates'].first['text'] should be "Amazon"
    And json['product']['affiliates'].first['href'] should be an amazon link

    And json['product']['affiliate_links'] should contain 1 element
    And json['product']['affiliate_links'].first should be an amazon link

    When I GET /products/1234567809129-55555.json
    Then I should see json

    And json['product']['affiliates'] should contain 1 element
    And json['product']['affiliates'].first['text'] should be "Codecheck"
    And json['product']['affiliates'].first['href'] should be a codecheck link

    And json['product']['affiliate_links'] should contain 1 element
    And json['product']['affiliate_links'].first should be a codecheck link

    When I GET /products/1234567809130-66666.json
    Then I should see json

    And json['product']['affiliates'] should contain 1 element
    And json['product']['affiliates'].first['text'] should be "buecher.de - Topseller"
    And json['product']['affiliates'].first['href'] should be a affilinet link

    And json['product']['affiliate_links'] should contain 1 element
    And json['product']['affiliate_links'].first should be a affilinet link
