Feature: Visit the root page

  As any kind of user
  I want to be able to browse to the root page of my2cents app
  So that I can see that it's not broken


  Scenario: Look at the root page

    Given the following products exist
      | name      |
      | Seife     |
      | Club Mate |
    Given the following comments exist
      | user  | body         | product   |
      | Klaus | Tastes great | Club Mate |
      | Peter | Good stuff   | Club Mate |
      | Peter | Stinks       | Seife     |

    When I go to the root page

    Then I should see "my2cents"
    And I should see "Klaus"
    And I should see "Tastes great"
    And I should see "3 comments on 2 products"


  Scenario: Look at about page

    When I go to the root page
    And I follow "About"
    Then I should see "About" within "h1"
