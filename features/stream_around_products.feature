Feature: Show activity stream grouped around products

  As a visitor of the root page
  I want to see fresh activities and live discussions
  So that I get the impression the site is active
  and that I can see which dialogs are taking place right now
  and that I am encouraged to react to the activity of other people.


  Scenario: Group comments by product

    Given the following products exist
    |  id | name      |
    | 123 | Club Mate |
    | 456 | Seife     |
    And the following comments exist
    | product   | body            | created_at    |
    | Club Mate | Prost           | 1.minute.ago  |
    | Club Mate | Best soft drink | 1.week.ago    |
    | Seife     | Meh             | 5.minutes.ago |
    And all products updated_at is set
   
    When I go to the root page
   
    Then I should see "Club Mate" before "Seife"
    And I should see "Best soft drink" before "Meh"
   
    And I should see "Prost" within "#product_123"
    And I should see "Best soft drink" within "#product_123"
   
    And I should see "Meh" within "#product_456"


  Scenario: Show only a few elements per product

    Given the following products exist
    |  id | name      |
    | 123 | Club Mate |
    | 456 | Seife     |
    And the following comments exist
    | product   | body           | created_at    |
    | Seife     | Nothing to say | 1.minute.ago  |
    | Club Mate | Prost          | 1.minute.ago  |
    | Club Mate | Third post     | 2.minutes.ago |
    | Club Mate | Second post    | 3.minutes.ago |
    | Club Mate | First post     | 4.minutes.ago |

    When I go to the root page

    Then I should see "Prost"
    And I should see "Second post"
    But I should not see "First post"

    And I should see "See all 4 comments" within "#product_123"
    But I should not see "See all" within "#product_456"


  Scenario: Do not show products that have no comment

    Given the following products exist
      | name      | 
      | Club Mate | 
    When I go to the root page
    Then I should not see "Club Mate"
