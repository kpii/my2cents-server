Feature: Create data anonymously, then register and move that data to an account

  As someone who uses my2cents for the first time
  After I clicked around a bit and created some data anonymously
  I want to register and I want that my data is associated with my new account


  Scenario: Create a scan, a comment and a rating and then register

    Given the following products exist
    | name      |          gtin |   id |
    | Club Mate | 1234567890123 | 4444 |
    And twitter would authenticate me
  
    When I go to the scan form
    And I fill in "scan_gtin" with "1234567890123"
    And I press "Create"

    And I go to the product page of "Club Mate"
    And I fill in "comment_body" with "Goodie"
    And I press "Create comment"

    And I choose "Like"
    And I press "Rate"
  
    And I follow "Login with Twitter"

    And I go to my profile page
    Then I should see "scanned 1 barcode"
    And I should see "left 1 comment"
    And I should see "liked 1 product"


  Scenario: Create a scan, a comment and a rating and then log in to an existing account

    Given twitter would authenticate me
    And the following users exist
    | name   | twitter_login | twitter_id |
    | kpi_k2 | kpi_k2        |   82675006 |

    And a product "1234567890123-4444" named "Club Mate"
    And a product "1234567890124-55555" named "Becks"

    And the following scans exist
    | user   |          gtin |
    | kpi_k2 | 1234567890123 |
    And the following comments exist
    | user   | product   | body |
    | kpi_k2 | Club Mate | Good |
    And the following ratings exist
    | user   | product   | value |
    | kpi_k2 | Club Mate | like  |

    When I scan 1234567890124

    And I go to the product page of "Becks"
    And I fill in "comment_body" with "Prost"
    And I press "Create comment"

    And I choose "Like"
    And I press "Rate"

    And I follow "Login with Twitter"
    And I go to my profile page

    Then I should see "scanned 2 barcodes"
    And I should see "left 2 comments"
    And I should see "liked 2 products"
