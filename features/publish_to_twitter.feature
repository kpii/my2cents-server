Feature: Post a comment and publish it to twitter

  As a my2cents user who is logged in using twitter
  I want to publish my my2cents comment to my twitter stream
  So that I have a wider audience


  Scenario: Post a comment and publish it to twitter

    Given I am authenticated with twitter
    And the following products exist
    | name      |
    | Club Mate |

    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "I love it"
    Then I should see "Publish comment on Twitter"

    When I check "publish_to_twitter"
    And I press "Create"

    Then my twitter status should get updated
    And the status should end with a short URL


  Scenario: Post a comment and do not publish it to twitter

    Given I am authenticated with twitter
    And the following products exist
    | name      |
    | Club Mate |

    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "I love it"
    And I uncheck "publish_to_twitter"
    And I press "Create"

    Then my twitter status should not get updated
