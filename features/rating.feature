Feature: Rating

  As a user
  I want to like or dislike a product
  So that I can share my opinion without typing text

  
  Scenario: Rate a product

    Given the following products exist
    | name  |
    | Seife |
  
    When I go to the product page of "Seife"
    Then I should see "Do you like this product?"
    And I should see "Like"
    And I should see "Dislike"
    And I should see "0 Likes"
    And I should see "0 Dislikes"
    When I choose "Like"
    And I press "Rate"
    Then I should see "You like this product"
    And I should see "1 Like"
    And I should see "0 Dislikes"
    But I should not see "Do you like this product?"
  
    When I choose "Dislike"
    And I press "Rate"
    Then I should see "You dislike this product"
    And I should see "0 Likes"
    And I should see "1 Dislike"
    But I should not see "Do you like this product?"

    When I choose "Neutral"
    And I press "Rate"
    Then I should not see "You dislike this product"
    And I should not see "You like this product"
    And I should see "0 Likes"
    And I should see "0 Dislikes"
    And I should see "Do you like this product?"

  
  Scenario: Different anonymous users rate a product

    Given the following products exist
    | name  |
    | Seife |
  
    When I go to the product page of "Seife"
    And I choose "Like"
    And I press "Rate"

    When I start a new browser session
    And I go to the product page of "Seife"
    And I choose "Dislike"
    And I press "Rate"

    Then I should see "You dislike this product"
    And I should see "1 Like"
    And I should see "1 Dislike"
  

  Scenario: Rate a product anonymously, then authenticate

    Given the following products exist
    | name  |
    | Seife |
    And twitter would authenticate me

    When I go to the product page of "Seife"
    And I choose "Like"
    And I press "Rate"
    Then I should see "You like this product"

    When I follow "Login with Twitter"
    And I go to the product page of "Seife"
    Then I should see "You like this product"

    When I follow "Log out"
    And I go to the product page of "Seife"
    Then I should not see "You like this product"


  Scenario: See ratings on user profile

    Given the following users exist
    | name |
    | til  |
    | sven |
    And the following ratings exist
    | user | product    | value   |
    | til  | Seife      | dislike |
    | til  | Schokolade | like    |
  
    When I go to the profile page of "til"
    Then I should see "liked 1 product"
    And I should see "disliked 1 product"
    And I should see "Likes" within "h2"
    And I should see "Schokolade" within ".likes"
    And I should see "Dislikes" within "h2"
    And I should see "Seife" within ".dislikes"

    When I go to the profile page of "sven"
    Then I should not see "liked"
    And I should not see "disliked"
    And I should not see "Likes" within "h2"
    And I should not see "Dislikes" within "h2"
