module JsonStepHelper
  def json(selector)
    eval("@json#{selector}")
  end
end

World(JsonStepHelper)

Then /^I should see json$/ do
  @json = JSON.parse(response.body)
end

Then /^json([^ ]+) should be "([^\"]*)"$/ do |selector, value|
  json(selector).should == value
end

Then /^json([^ ]+) should be an empty string$/ do |selector|
  json(selector).should == ""
end

Then /^json([^ ]+) should be an empty array$/ do |selector|
  json(selector).should == []
end

Then /^json([^ ]+) should be nil|null$/ do |selector|
  json(selector).should be_nil
end

Then /^json([^ ]+) should not be nil|null$/ do |selector|
  json(selector).should_not be_nil
end

Then /^json([^ ]+) should be (\d+)$/ do |selector, int|
  json(selector).should == int.to_i
end

Then /^json([^ ]+) should be (\d+\.\d+)$/ do |selector, float|
  json(selector).should == float.to_f
end

Then /^json([^ ]+) should be a number$/ do |selector|
  json(selector).to_i.should > 0
end

Then /^json([^ ]+) should contain ([^ ]) elements?$/ do |selector, count|
  json(selector).length.should == count.to_i
end

Then /^json([^ ]+) should not contain a ([^ ]+) item$/ do |selector, element|
  json(selector)[element].should be_nil
end

Then /^json([^ ]+) should be the user id of "([^\"]*)"$/ do |selector, name|
  json(selector).should == User.find_by_name!(name).id
end

Then /^json([^ ]+) should be a recent date value$/ do |selector|
  Time.parse(json(selector)).should > 5.seconds.ago
end

Then /^json([^ ]+) should only include "([^\"]*)"$/ do |selector, keys|
  actual_keys = json(selector).keys
  expected_keys = keys.split(",").map(&:strip)

  (actual_keys - expected_keys).should be_empty
end

When /^looking at json([^ ]+)$/ do |selector|
  @json_string = json(selector)
end

Then /^the json string should contain "([^\"]*)"$/ do |value|
  @json_string.should include(value)
end

Then /^json([^ ]+) should be an amazon link$/ do |selector|
  link = json(selector)
  link.should match(/www.amazon.com/)
  link.should match(/my2cents0f-20/)
end

Then /^json([^ ]+) should be a codecheck link$/ do |selector|
  link = json(selector)
  link.should match(/www.codecheck.info/)
  link.should match(/product.pro$/)
end

Then /^json([^ ]+) should be a affilinet link$/ do |selector|
  link = json(selector)
  link.should match(/partners.webmasterplan.com/)
end

Then /^print the json$/ do
  puts @json.inspect
end
