When /^I (GET|DELETE) (.+)$/ do |method, url|
  if url =~ /^the created (\w+) resource with "([^\"]*)" appended$/
    url = @location_headers[$1] + $2
  end

  opts = {}
  opts[:user_agent] = @user_agent if @user_agent

  send(method.downcase.to_sym, url, nil, opts)
end

When /^I (PUT|POST) ([^ ]+) "([^\"]*)"$/ do |method, url, data|
  opts = {}
  opts[:user_agent] = @user_agent if @user_agent

  send(method.downcase, url, data, opts)
end

When /^I (PUT|POST) ([^ ]+) with content_type ([^ ]+)$/ do |method, url, content_type, data|
  opts = { :content_type => content_type }
  opts[:user_agent] = @user_agent if @user_agent

  send(method.downcase, url, data, opts)
end

Then /^I should receive a (\d+ .*) response$/ do |code|
  response.response_code.should == code.to_i
end

Then "print the page" do
  puts page.body
end

Given /^my user agent is "([^\"]*)"$/ do |user_agent|
  # For the methods using the integration session
  @user_agent = user_agent

  # For the standard capybara requests
  page.driver.header "User-Agent", user_agent
end

Then /^I should see "([^\"]*)" before "([^\"]*)"$/ do |first, second|
  page.body.should match(/#{first}.*#{second}/m)
end

Then /^I should not see "([^\"]*)" within xpath "([^\"]*)"$/ do |text, selector|
  page.should_not have_xpath(selector, :text => text)
end

Then /^I should see the link "([^\"]*)" to "([^\"]*)"$/ do |text, href|
  page.should have_xpath("//a[@href='#{href}']", :text => text)
end

Then /^I should not see a delete form$/ do
  page.should_not have_xpath("//form//input[@value='Delete']")
end

Then /^the response should have an? "([^\"]*)" header$/ do |header|
  @header_value = headers[header]
  @header_value.should_not be_nil
end

When /^I request the URL of the header value as json$/ do
  get "#{@header_value}.json"
end
