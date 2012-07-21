Feature: Show inbox with new activity that I am interested in

  As a recurring user of my2cents
  I want to be informed on activities by other users on products that I'm interested in
  So that I get feedback on my own activities and that I know I don't miss anything
  and so I can reply in time.

  TODO: write scenario to also specify that scans and ratings are
  included in a users' products

  
  Scenario: See activities on products

    Given the following users exist
    | name |
    | Eva  |
    And the following products exist
    | name      |
    | Club Mate |

    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "I like it"
    And I press "Create comment"

    And "Eva" posts the following comment
    | product   | body    |
    | Club Mate | I don't |
    And I go to my inbox

    Then I should see "Eva"
    And I should see "I don't"
    But I should not see "I like it"


  Scenario: See events split by already seen and yet unseen content

    Given the following users exist
    | name |
    | Eva  |
    And the following products exist
    | name      |
    | Club Mate |

    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "I like it"
    And I press "Create comment"

    And "Eva" posts the following comment
    | product   | body  |
    | Club Mate | Prost |
    And I go to my inbox
    Then I should see "Prost" within ".unseen"

    When I go to my inbox
    Then I should see "Prost" within ".seen"

    When "Eva" posts the following comment
    | product   | body  |
    | Club Mate | Mahlzeit  |
    And I go to my inbox 
    Then I should see "Mahlzeit" within ".unseen"
    And I should see "Prost" within ".seen"
