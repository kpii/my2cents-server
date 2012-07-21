Feature: Authenticate from a client app with a client token

  As a new user of my2cents who just downloaded the app
  I want to use the app right away and later connect it to my twitter account
  and I want to access the same account data through the web
  so that I benefit from the advantages of each access method.


  = API Documentation

  == Create a client_token

  After installation an app should generate a secure random identifier
  string, preferably something like a GUID, and store it
  permanently. Please make an effort to generate a number that can not
  be guessed easily. Using a library that generates secure random
  GUIDs is ok - using increasing numbers or a hardware item id is not
  ok.

  The app must not use this token for any other purpose than
  described here.


  == Use the client_token in every API request

  Every API request from the app to the my2cents server must
  include this identifier in the http Cookie header with the cookie
  name 'client_token'.

  You can simulate it with curl like this:

  curl -H "Cookie: client_token=thisisatotallyrandomandsecurestring" http://my2cents.mobi/comments.json


  == Make anonymous API requests

  my2cents apps should be usable right away after installation
  including scanning, posting comments and rating, without requiring
  the user to register first. Therefore API requests can be made
  anytime as long as they include a random secure client_token value
  as described above.


  == Authenticate the user

  Eventually the user might want to associate the installed app with a
  new or existing my2cents user account.

  To start the authentication process with twitter, start a browser at
  the address

  http://my2cents.mobi/login?client_token={current_client_token}

  This will redirect to twitter where the user will be asked by
  twitter to log in and authorize the application.

  After successful authorization, the browser will eventually be
  redirected to the location http://my2cents.mobi/auth/success - you
  can intercept this and let your app take over control after that
  again. (TODO for the iphone the target URL is currently just
  http://my2cents.mobi/)

  Please note that the authorization process may either simply add a
  name to the previously anonymous user, or, if the user already has
  registered on my2cents before either through another app or through
  the web, then this will simply add another client_token to the list
  of allowed accesses for that user account. Anonymously generated
  data from before the authorization will be migrated over to the
  existing account. Propably this does not have an effect on an app's
  design, but it's good to know in any case.


  == Log out

  In the case that a user wants to log out, simply delete the
  client_token permanently from your storage and generate a new one.
  


  Scenario: Register with client token and then use the app

    Given the following products exist
      |   id |          gtin |
      | 4444 | 1234567809128 |

    When I GET /login?client_token=abcdef123456
    Then I should receive a redirect to "/oauth/authenticate" on twitter with oauth_token
    When I request and display that page to my user
    And twitter finally redirects me to "http://my2cents.mobi/oauth_callback?oauth_token=fake"
    And I GET /oauth_callback?oauth_token=fake

    When I include the cookie "client_token" with value "abcdef123456" in every request
    And I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"As registered user"}}
    """
    Then I should receive a 201 created response

    When I GET /products/1234567809128-4444.json
    And I should see json
    And json['product']['comments'].first['user']['name'] should be "kpi_k2"


  Scenario: Use client app anonymously, then register

    Given I include the cookie "client_token" with value "abcdef123456" in every request

    And the following products exist
      |   id |          gtin |
      | 4444 | 1234567809128 |

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"As not yet registered user"}}
    """
    Then I should receive a 201 created response

    When I GET /products/1234567809128-4444.json
    And I should see json
    And json['product']['comments'].first['user']['name'] should be "Anonymous"

    When I clear all cookies
    And I GET /login?client_token=abcdef123456
    Then I should receive a redirect to "/oauth/authenticate" on twitter with oauth_token
    When I request and display that page to my user
    And twitter finally redirects me to "http://my2cents.mobi/oauth_callback?oauth_token=fake"
    And I GET /oauth_callback?oauth_token=fake

    When I GET /products/1234567809128-4444.json
    And I should see json
    And json['product']['comments'].first['user']['name'] should be "kpi_k2"


  Scenario: Use client app anonymously, then login to an existing account

    Given twitter would authenticate me
    And the following users exist
    | name   | twitter_login | twitter_id |
    | kpi_k2 | kpi_k2        |   82675006 |

    And the following products exist
    |   id |           gtin | name      |
    | 4444 | 1234567809128 | Club Mate |
    And the following comments exist
    | user   | product   | body     |
    | kpi_k2 | Club Mate | From web |

    And I include the cookie "client_token" with value "abcdef123456" in every request

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"From client"}}
    """

    When I clear all cookies
    And I GET /login?client_token=abcdef123456
    Then I should receive a redirect to "/oauth/authenticate" on twitter with oauth_token
    When I request and display that page to my user
    And twitter finally redirects me to "http://my2cents.mobi/oauth_callback?oauth_token=fake"
    And I GET /oauth_callback?oauth_token=fake

    When I GET /products/1234567809128-4444.json
    And I should see json
    And json['product']['comments'][0]['body'] should be "From client"
    And json['product']['comments'][0]['user']['name'] should be "kpi_k2"
    And json['product']['comments'][1]['body'] should be "From web"
    And json['product']['comments'][1]['user']['name'] should be "kpi_k2"

    When I clear all cookies
    And I include the cookie "client_token" with value "abcdef123456" in every request
    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"Now from authenticated client"}}
    """
    When I GET /products/1234567809128-4444.json
    And I should see json
    And json['product']['comments'][0]['body'] should be "Now from authenticated client"
    And json['product']['comments'][0]['user']['name'] should be "kpi_k2"


  @allow-rescue
  Scenario: Reject a client token which is too short

    When I include the cookie "client_token" with value "null" in every request
    And I GET /comments.json
    Then I should receive a 400 Bad Request response
