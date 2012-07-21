Feature: Display comments and hide elements which are redundant in the context

  Background:
    Given the following comments exist
    | user  | product | body   |
    | Klaus | Astra   | I like |


  Scenario: Display comments on user page

    When I go to the user page of "Klaus"
    Then I should see "I like" within "#comments"
    And I should see "Astra" within "#comments"
    But I should not see "Klaus" within "#comments"


  Scenario: Display comments on product page
    
    When I go to the product page of "Astra"
    Then I should see "I like" within "#comments"
    And I should see "Klaus" within "#comments"
    But I should not see "Astra" within "#comments"


  Scenario: View a fragment with recent comments

    When I go to /comments/recent
    Then I should see "I like"


  Scenario: Display comment with a link
    
    Given the following comments exist
    | body                                |
    | Look here: http://slashdot.org/1234 |

    When I go to the root page
    Then I should see the link "http://slashdot.org/1234" to "http://slashdot.org/1234"
