Feature: Support old product URLs

  As someone who follows an old my2cents product URL
  I want to see a product page
  So that I don't loose the connection to existing products

  
  Scenario: Access old product URL, without the id extension

    Given the following products exist
      |   id |          gtin | name       |
      | 4444 | 1234567809128 | Alpro Soya |
    When I go to /products/1234567809128

    Then I should be on the product page of "Alpro Soya"
    And I should be on /products/1234567809128-4444
    And I should see "Alpro Soya" within "h1"
