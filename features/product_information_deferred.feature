@no-txn
Feature: Update product information with data from external services

  As a user who wants product information and provides a gtin
  I want to get a good guess from external services
  But I don't want to wait more than a couple of seconds for it.

  The timeout that we wait for external responses is 10 seconds. Note
  that this value is calculated into some sleep times in the
  scenarios.


  Background:
    Given every scan and product request is about the same gtin
    

  Scenario: Answer arrives after a few seconds

    Given the codecheck request takes 4 seconds to complete
    And codecheck responds with "Palmolive Rasierwasser"
    And background workers are running

    When I create a scan
    Then the product of the scan should be empty

    When 2 seconds pass by
    Then the product of the scan should be empty

    When 5 more seconds pass by
    Then the product of the scan should be "Palmolive Rasierwasser"


  Scenario: Answer arrives too late, default to Unknown Product, do not update later

    Given the codecheck request takes 15 seconds to complete
    And codecheck responds with "Palmolive Rasierwasser"
    And background workers are running

    When I create a scan
    Then the product of the scan should be empty

    When 2 seconds pass by
    Then the product of the scan should be empty

    When 9 more seconds pass by
    Then the product of the scan should be "Unknown Product (1234567890128)"

    When 5 more seconds pass by
    Then the product of the scan should be "Unknown Product (1234567890128)"


  Scenario: External answer is too late, product was updated in the meantime

    Given the codecheck request takes 15 seconds to complete
    And codecheck responds with "Kirschyoghurt"
    And background workers are running

    When I create a scan
    And 11 seconds pass by
    Then the product of the scan should be "Unknown Product (1234567890128)"

    When I update the product with "Gute Seife"
    And 6 seconds pass by

    Then the product of the scan should be "Gute Seife"


  Scenario: Different answers at different times, do not update later

    Given the amazon request takes 3 seconds to complete
    And amazon responds with "Michael Jackson DVD"

    And the codecheck request takes 15 seconds to complete
    And codecheck responds with "Palmolive Rasierwasser"
    And background workers are running

    When I create a scan
    Then the product of the scan should be empty

    When 12 seconds pass by
    Then the product of the scan should be "Michael Jackson DVD"

    When 7 more seconds pass by
    Then the product of the scan should be "Michael Jackson DVD"


  Scenario: Immediately available answer, no external info

    Given there is a upcdatabase entry "Peanut Butter"
    And background workers are running

    When I create a scan
    Then the product of the scan should be empty

    When 5 seconds pass by
    Then the product of the scan should be "Peanut Butter"


  Scenario: Immediately available answer, conflicts later with external info

    Given there is a upcdatabase entry "Peanut Butter"

    And codecheck responds with "Kirschyoghurt"
    And the codecheck request takes 3 seconds to complete
    And background workers are running

    When I create a scan
    Then the product of the scan should be empty

    When 7 seconds pass by
    Then the product of the scan should be "Kirschyoghurt"


  Scenario: Immediately available answer, conflicts with too late external info

    Given there is a upcdatabase entry "Peanut Butter"

    And codecheck responds with "Kirschyoghurt"
    And the codecheck request takes 15 seconds to complete
    And background workers are running

    When I create a scan
    Then the product of the scan should be empty

    When 11 seconds pass by
    Then the product of the scan should be "Peanut Butter"

    When 6 more seconds pass by
    Then the product of the scan should be "Peanut Butter"
