Feature: Post a comment on a product 

  In order to share my product experience
  I want to post a comment on a product

  Background:
    Given the following products exist
    | name      |
    | Club Mate |


  Scenario: Post a comment, anonymously

    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "I hate it"
    And I press "Create comment"

    Then I should see "I hate it" within "#comments"
    And I should see "Anonymous" within "#comments li .user_name"
    And I should see the image "http://www.example.com/images/anonymous.png?4" within "#comments li"
    And I should see "less than a minute ago"

    When I fill in "comment_body" with "I love it"
    And I press "Create"
    
    Then I should see "Thank you"
    And I should see "I love it" before "I hate it"


  Scenario: Post a comment, authenticated

    Given I am authenticated with twitter
     
    When I go to the product page of "Club Mate"
    When I fill in "comment_body" with "I hate it"
    And I press "Create comment"

    Then I should see "I hate it" within "#comments"
    And I should see "kpi_k2" within "#comments"

    When I fill in "comment_body" with "I hate it and here is why http://flickr.com/img/120398412"
    And I press "Create comment"

    Then I should see "I hate it and here is why http://flickr.com/img/120398412" within "#comments"
    And I should see "kpi_k2" within "#comments"


  Scenario: Post some spam comment, anonymously
    When I go to the product page of "Club Mate"
    And I fill in "comment_body" with "I hate it"
    And I press "Create comment"

    Then I should see "I hate it" within "#comments"

    When I fill in "comment_body" with "http://connect.masslive.com/user/Carbon14Datieob18/index.html Carbon 14 Dating and http://connect.masslive.com/user/SexYouTubevtk37/index.html Sex You Tube and http://connect.masslive.com/user/WhiteGirlsDacjt47/index.html White Girls Dating Latin Boys Seattle and http://connect.masslive.com/user/BritneySexTafcp12/index.html Britney Sex Tape and http://connect.masslive.com/user/JewishDatingfvh59/index.html Jewish Dating Portland Oregon"
    And I press "Create comment"

    Then I should not see "http://connect.masslive.com/user/Carbon14Datieob18/index.html" within "#comments"
    And I should not see "Thank you"

    When I fill in "comment_body" with "https://connect.masslive.com/user/Carbon14Datieob18/index.html Carbon 1"
    And I press "Create comment"

    Then I should not see "https://connect.masslive.com/user/Carbon14Datieob18/index.html" within "#comments"
    And I should not see "Thank you"

