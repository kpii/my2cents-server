Feature: Show information about a user

  As a visitor of my2cents
  I want to find out more about someone who posted a comment
  So that I can get to know him and see his or her other comments


  Scenario: Browse to a user page

  Given the following users exist
  | name |
  | Hugo |
  And the following comments exist
  | user | product             | body        |
  | Hugo | Müllers Saure Sahne | Ganz gut    |
  | Hugo | Müllers Saure Sahne | Ganz gut    |
  | Hugo | Peters Saure Sahne  | Viel besser |

  When I go to the root page
  And I follow "Hugo"
  Then I should see "Hugo" within "h1"
  And I should see "left 3 comments"
  And I should see "on 2 products"
