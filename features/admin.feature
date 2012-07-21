Feature: admin

As a Admin i want to get more Information about the Productinformation
So that i can see where it comes from


Scenario: Log in as admin

  Given twitter would authenticate me
  And my twitter name is "user1"
  When I go to the root page
  And I follow "Login with Twitter"
  Then I should see "Logged in as user1 (admin)"

  When I go to /admin/products
  Then I should see "products" within "h1"


@allow-rescue
Scenario: Log in as non admin

  Given twitter would authenticate me
  When I go to the root page
  And I follow "Login with Twitter"
  Then I should not see "(admin)"

  When I go to /admin/products
  Then I should see "Forbidden"


Scenario: Browse product as admin

  Given the following products exist
  |   id | gtin | name      |
  | 4444 | 1234 | club mate |
  And I am logged in as admin
  When I go to the product page of "club mate"
  Then I should see "club mate"
  And I should see "admin"
  When I follow "(admin)" 
  Then I should see "Admin Product Info for 1234-4444"


Scenario: List of all infos per product

  Given the following products exist
  | name      |
  | club mate |
  And I am logged in as admin
  When I go to /admin/products
  Then I should see "club mate"


Scenario: Delete a comment

  Given the following products exist
  |   id | gtin | name      |
  | 4444 | 1234 | club mate |
  And the following comments exist
  | product   | body        |
  | club mate | good        |
  | club mate | just a test |
  And I am logged in as admin

  When I go to the product page of "club mate"
  And I follow "less than a minute ago" within "#comments li:first-child"

  When I press "Delete"
  Then I should be on the product page of "club mate"
  And I should see "good"
  But I should not see "just a test"


Scenario: Do not see delete button as non admin

  Given the following products exist
  | name      | 
  | club mate |
  And the following comments exist
  | product   | body        |
  | club mate | good        |
  And twitter would authenticate me
  And I go to the root page
  And I follow "Login with Twitter"

  When I go to the product page of "club mate"
  And I follow "less than a minute ago"
  Then I should not see a delete form

