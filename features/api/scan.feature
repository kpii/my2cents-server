Feature: Scan a product

  As a user of the API
  I want to save that I scanned a product
  So that I have it in my history on the server and can post a comment


  API Documentation

  To record when a user scans a barcode you have to create a scan
  resource. A scan resource represents a single scan event and contains
  the following information:
    - a user
    - creation date
    - product (can be null initially)
    - geolocation (optional)
  
  It is also the starting point to find out the product resource (which
  will be created if necessary) that represents the product that the
  user scanned. You need to know the product resource in order to post a
  comment.
  
  Not always does a barcode number map to a single product.
  
  If the number has an invalid format, e.g. when the user scanned a
  barcode that can not belong to a product, then the creation of the
  scan resource will fail with an error.
  
  Otherwise the creation of the scan resource will succeed.

  The process to resolve a gtin number to a product can take some time
  on the server - sometimes up to 10 seconds. To avoid blocking an
  http request for the length of that process, the server immediately
  creates the scan resource, but indicates that the process is still
  running by returning null for the product element:
  {'scan':{'product':null}}

  If that element is null we suggest you GET /scans/{id} after 2
  seconds, and again until it is not null anymore.

  Eventually the scan resource will have at least one, but maybe more
  products associated with it. Especially for the short variant of ean
  numbers with 8 digits it is often likely that a barcode has several
  product matches. The my2cents server will make a best guess which is
  the most likely one, possibly taking into account the users' history
  and location, and return this product in the product json element.

  In the case that the server could not find information for this gtin
  but believes it is a valid format, the name of the product will be
  set to something like 'Unknown Product'. This is a completely valid
  product resource and can be treated as such, e.g. to post a comment.

  Once the polling is finished and the scan resource contains a
  product you can display the product information to the user. Which
  API requests need to be done then depend on whether the user is
  happy with the information she sees or not.

  If she is not happy, the client app should request
  /scans/{id}/options.json - this list can contain further different
  product options. If the user is not happy with any of the options
  either, or if the options are empty, then the user might want to
  create a new product. This is a POST /products. Either way, by
  selecting an option or by creating a new product, a new product_key
  is obtained, different from the one that was the servers' initial
  guess in the scan resource. The client app _must_ update the scan
  with PUT /scans/{id} once a new product_key has been selected by
  user interaction. This is important so that activities like "Franz
  scanned Shaving Foam" are recorded and displayed on the server
  correctly.

  The resulting product_key can then be used for further actions such
  as posting a comment or rating.


  Background:
    Given I include the cookie "client_token" with value "abcdef123456" in every request
    And the client_token "abcdef123456" maps to a user named "Franz"

  @no-txn
  Scenario: Scan a barcode, product available after some seconds
    Given the id for the next generated scan would be 123
    Given the codecheck request takes 4 seconds to complete
    And codecheck responds with "Palmolive Rasierwasser"
    And the id for the next generated product would be 55555
    And background workers are running

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['scan']['product'] should be nil
    And json['scan']['id'] should be 123

    When I GET /scans/123.json
    Then I should receive a 200 OK response
    And I should see json
    And json['scan']['product'] should be nil

    When 2 seconds pass by
    And I GET /scans/123.json
    Then I should receive a 200 OK response
    And I should see json
    And json['scan']['product'] should be nil

    When 5 more seconds pass by
    And I GET /scans/123.json
    Then I should receive a 200 OK response
    And I should see json
    And json['scan']['product']['name'] should be "Palmolive Rasierwasser"
    And json['scan']['product']['key'] should be "1234567809128-55555"

  Scenario: Scan a barcode, product not known, simply add a comment

    Given a product "1234567809128-4444" named "Unknown Product (1234567809128)"

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['scan']['product']['name'] should be "Unknown Product (1234567809128)"
    And json['scan']['product']['key'] should be "1234567809128-4444"

    And json['scan']['product_id'] should be nil
    And json['scan']['product']['id'] should be nilp

    When I POST /comments.json with content_type application/json
    """
    {"comment":{"product_key":"1234567809128-4444","body":"I love it"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['comment']['body'] should be "I love it"


  Scenario: Scan a barcode, product not known, add product data

    Given a product "1234567809128-4444" named "Unknown Product (1234567809128)"

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['scan']['product']['name'] should be "Unknown Product (1234567809128)"
    And json['scan']['product']['key'] should be "1234567809128-4444"

    When I PUT /products/1234567809128-4444.json with content_type application/json
    """
    {"product":{"name":"Ritter Sport Dunkle Voll Nuss"}}
    """
    Then I should receive a 200 OK response

    When I GET /products/1234567809128-4444.json
    Then I should see json
    And json['product']['name'] should be "Ritter Sport Dunkle Voll Nuss"

    When I go to the user page of "Franz"
    Then I should see "Ritter Sport Dunkle Voll Nuss" within ".scans"

  Scenario: Scan a barcode, product known and correct

    Given a product "1234567809128-4444" named "Alpro Soya"

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['scan']['product']['name'] should be "Alpro Soya"
    And json['scan']['product']['key'] should be "1234567809128-4444"

    When I go to the user page of "Franz"
    Then I should see "Alpro Soya" within ".scans"


  Scenario: Scan a barcode, product known and not correct, no other options

    Given a product "1234567809128-4444" named "Seife 3000"
    And the id for the next generated product would be 55555

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And the response should have a Location header pointing to the created scan resource
    And the Location header should match "^/scans/\d+$"
    And I should see json
    And json['scan']['product']['name'] should be "Seife 3000"
    And json['scan']['product']['key'] should be "1234567809128-4444"
    
    When I GET the created scan resource with "/options.json" appended
    Then I should see json
    And json.size should be 1
    And json.first['product']['name'] should be "Seife 3000"
    
    When I POST /products.json with content_type application/json
    """
    {"product":{"gtin":"1234567809128","name":"Club Mate"}}
    """
    Then I should receive a 201 created response
    And the response should have a Location header pointing to the created product resource
    And I should see json
    And json['product']['key'] should be "1234567809128-55555"

    When I PUT the created scan resource with ".json" appended
    """
    {"scan":{"product_key":"1234567809128-55555"}}
    """
    Then I should receive a 200 OK response
    
    When I go to the user page of "Franz"
    Then I should see "Club Mate" within ".scans"
    But I should not see "Seife 3000" within ".scans"

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['scan']['product']['name'] should be "Club Mate"
    And json['scan']['product']['key'] should be "1234567809128-55555"

  Scenario: Scan a barcode, product known and not correct, other options, one of these correct

    Given a product "1234567809128-4444" named "Seife 3000" from CodecheckResponse
    And a product "1234567809128-55555" named "Club Mate" from AmazonUsResponse
    And the following comments exist
    | product    | body        |
    | Seife 3000 | Washes well |
    | Club Mate  | Great drink |

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And the response should have a Location header pointing to the created scan resource
    And I should see json
    And json['scan']['product']['key'] should be "1234567809128-4444"
    And json['scan']['product']['name'] should be "Seife 3000"

    When I GET the created scan resource with "/options.json" appended
    Then I should see json
    And json.size should be 2
    And json[0]['product']['name'] should be "Seife 3000"
    And json[1]['product']['name'] should be "Club Mate"

    When I PUT the created scan resource with ".json" appended
    """
    {"scan":{"product_key":"1234567809128-55555"}}
    """
    Then I should receive a 200 OK response

    When I go to the user page of "Franz"
    Then I should see "Club Mate" within ".scans"
    But I should not see "Seife 3000" within ".scans"


  Scenario: Scan a barcode, product known and not correct, other options, none of these correct

    Given a product "1234567809128-4444" named "Seife 3000" from CodecheckResponse
    And a product "1234567809128-55555" named "Club Mate" from AmazonUsResponse
    And the following comments exist
    | product    | body        |
    | Seife 3000 | Washes well |
    | Club Mate  | Great drink |
    And the id for the next generated product would be 666666

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128"}}
    """
    Then I should receive a 201 created response
    And the response should have a Location header pointing to the created scan resource
    And I should see json
    And json['scan']['product']['key'] should be "1234567809128-4444"
    And json['scan']['product']['name'] should be "Seife 3000"

    When I GET the created scan resource with "/options.json" appended
    Then I should see json
    And json.size should be 2
    And json[0]['product']['name'] should be "Seife 3000"
    And json[1]['product']['name'] should be "Club Mate"

    When I POST /products.json with content_type application/json
    """
    {"product":{"gtin":"1234567809128","name":"Shaving Foam"}}
    """
    Then I should receive a 201 created response
    And the response should have a Location header pointing to the created product resource
    And I should see json
    And json['product']['key'] should be "1234567809128-666666"
    And json['product']['name'] should be "Shaving Foam"

    When I PUT the created scan resource with ".json" appended
    """
    {"scan":{"product_key":"1234567809128-666666"}}
    """
    Then I should receive a 200 OK response

    When I go to the user page of "Franz"
    Then I should see "Shaving Foam" within ".scans"
    But I should not see "Seife 3000" within ".scans"
    And I should not see "Club Mate" within ".scans"


  @allow-rescue
  Scenario: Updating the scan of another user is forbidden

    Given a product "1234567809128-4444" named "Alpro Soya"
    And the following scans exist
      |   id | product    | user  |
      | 1234 | Alpro Soya | Fritz |

    When I PUT /scans/1234.json with content_type application/json
    """
    {"scan":{"product_key":"1234567809128-4444"}}
    """
    Then I should receive a 403 Not Authorized response


  Scenario: Create a scan with location (should simply not raise error for now)

    When I POST /scans.json with content_type application/json
    """
    {"scan":{"gtin":"1234567809128","latitude":47.369059,"longitude":8.406601}}
    """
    Then I should receive a 201 created response
    And I should see json
    And json['scan']['latitude'] should be 47.369059
    And json['scan']['longitude'] should be 8.406601
