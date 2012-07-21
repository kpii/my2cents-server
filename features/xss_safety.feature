Feature: To be safe from XSS attacks

  As a logged in my2cents user
  I don't want others to be able to mess with my account in my name
  

  Scenario: Post a comment with html and then view it

    Given the following products exist
    | name      |
    | Club Mate |

    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "<i>evil</i> foo"
    And I press "Create comment"

    Then I should see "<i>evil</i> foo"
    But I should not see "evil" within xpath "//i"
