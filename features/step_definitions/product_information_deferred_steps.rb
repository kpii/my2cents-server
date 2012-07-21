Given /^every scan and product request is about the same gtin$/ do
  @gtin = "1234567890128"
end

Given /^codecheck responds with "([^\"]*)"$/ do |name|
  body = ERB.new(
    File.read(Rails.root.join('features/fixtures/codecheck_lookup.json.erb'))).result(binding)

  stub_request(:get, 
    %r{^https://username:xxxxxxxxx@www.codecheck.info/WebService/rest/prod/ean/7/#{@gtin}.*}).
    to_return do |request|
      if @delay['codecheck']
        sleep @delay['codecheck'].to_i 
      end
      { :headers => { 'Content-Type' => 'application/json;charset=UTF-8' },
        :body => body }
    end
end

Given /^amazon responds with "([^\"]*)"$/ do |name|
  stub_request(:get, %r{^http://ecs.amazonaws.com/onca/xml\?.*ItemId=#{@gtin}.*}).
    to_return do
      if @delay['amazon']
        sleep @delay['amazon'].to_i 
      end
      { :headers => { 'Content-Type' => 'application/json;charset=UTF-8' },
        :body => ERB.new(File.read(
          Rails.root.join('features/fixtures/amazon_lookup.xml.erb'))).result(binding) }
    end
end

Given /^there is a upcdatabase entry "([^\"]*)"$/ do |name|
  UpcDatabaseInfo.make({
      :gtin => @gtin,
      :name => name    })
end

Given /^the (\w+) request takes (\d+) seconds to complete$/ do |source, seconds|
  @delay ||= {}
  @delay[source] = seconds
end

When /^I create a scan$/ do
  steps %Q(
    When I go to the root page
    And I follow "Add a product"
    And I fill in "scan_gtin" with "#{@gtin}"
    And I press "Create"
  )
  @last_scan = Scan.last
end

When /^I update the product with "([^\"]*)"$/ do |name|
  @last_scan.product.update_attribute(:name, name)
end

Then /^the product of the scan should be empty$/ do
  @last_scan.reload.product.should be_nil
end

Then /^the product of the scan should be "([^\"]*)"$/ do |name|
  @last_scan.reload.product.name.should == name
end

When /^(\d+) (?:more )?seconds pass by$/ do |seconds|
  #Timecop.travel(seconds.to_i.seconds.from_now)
  sleep seconds.to_i
end
