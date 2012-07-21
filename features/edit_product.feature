Feature: Edit product information

  As a user of my2cents
  I want to be able to add or change the name of a product
  So that I can improve the data and the value of my comments


  Scenario: Set name of unknown product

    Given there is an unknown product with the key 1234567890123-4444

    When I go to /products/1234567890123-4444
    Then I should see "Set name"

    When I follow "Set name"
    Then the "product[name]" field should not contain "Unknown"
    And I should see "Cancel"
    When I fill in "product_name" with "Bauer Yoghurt"
    And I press "OK"

    Then I should see "Thank you!"
    And I should be on /products/1234567890123-4444
    And I should see "Bauer Yoghurt" within "h1"
    But I should not see "Set name"
