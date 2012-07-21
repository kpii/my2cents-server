Feature: Scan barcodes

  As a user
  I want to save that I scanned a product
  So that I have it in my history on the server and can add a comment


  Background:
    Given the following products exist
    | name      |          gtin |
    | Club Mate | 5411188081852 |


  Scenario: Follow link from root page, add a scan

    Given I am authenticated with twitter

    When I go to the root page
    And I follow "Add a product"
    And I fill in "scan_gtin" with "5411188081852"
    And I press "Create"
    And I follow "Club Mate"
    Then I should be on the product page of "Club Mate"

    When I go to my profile page
    Then I should see "Club Mate" within ".scans"
