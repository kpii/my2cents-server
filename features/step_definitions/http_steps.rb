Then /^I should receive a (\d+) response$/ do |code|
  response.response_code.should == code.to_i
end

Then /^the response should have a Location header pointing to the created (.*) resource$/ do |resource|
  location_header = response.headers['Location']
    
  location_header.should_not be_nil

  @location_headers ||= {}
  @location_headers[resource] = location_header
end

Then /^the Location header should match "([^\"]*)"$/ do |regexp|
  response.headers['Location'].should match(Regexp.new(regexp))
end

When /^I PUT the created scan resource with "([^\"]*)" appended$/ do |append, data|
  put [@location_headers["scan"], append].join, data, :content_type => "application/json"
end
