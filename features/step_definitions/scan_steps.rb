When /^I scan (\d+)$/ do |gtin|
  steps %Q(
    When I go to the root page
    And I follow "Add a product"
    And I fill in "scan_gtin" with "#{gtin}"
    And I press "Create"
  )
end
