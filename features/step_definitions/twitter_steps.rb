Then /^my twitter status should get updated$/ do
  WebMock.should have_requested(:post, "https://twitter.com/statuses/update.json")
end

Then /^my twitter status should not get updated$/ do
  WebMock.should_not have_requested(:post, 'https://twitter.com/statuses/update.json')
end

Given /^twitter would authenticate me$/ do
  stub_request(:get, %r{^https://twitter.com/oauth/authenticate.*}).
    to_return(:status => 302, :headers => { 'Location' => 'http://www.example.com/oauth_callback?oauth_token=fake' })
end

Given /^my twitter name is "user1"$/ do
  stub_request(:get, 'https://twitter.com/account/verify_credentials.json').
    to_return(File.read(Rails.root.join('features', 'fixtures', 'verify_credentials_admin.json')))
end


Given /^twitter would allow me access$/ do
  stub_request(:get, %r{^https://twitter.com/oauth/authenticate.*}).
    to_return(:status => 302, :headers => { 'Location' => 'http://www.example.com/oauth_callback?oauth_token=fake' })
end

Given /^twitter would not allow me access$/ do
  stub_request(:get, %r{^https://twitter.com/oauth/authenticate.*}).
    to_return(:status => 302, :headers => { 'Location' => 'http://www.example.com/oauth_callback?denied=fake' })
end

Given /^I am authenticated with twitter$/ do
  Given "twitter would authenticate me"
  When "I go to \"the root page\""
  When "I follow \"Login with Twitter\""
end

Then /^the status should end with a short URL$/ do
  @last_twitter_status.should match(/ http:\/\/m2c.at\/[0-9a-zA-Z]+$/)
end

When /^I request and display that page to my user$/ do
  # Do nothing
end

When /^twitter finally redirects me to "([^\"]*)"$/ do |arg1|
  # Do nothing
end

Then /^I should receive a redirect to "([^\"]*)" on twitter with oauth_token$/ do |path|
  response.response_code.should == 302
  uri = URI.parse(response.headers['Location'])
  uri.host.should == "twitter.com"
  uri.path.should == path
end

Given /^getting a request token from twitter fails twice$/ do
  Kernel.stub!(:sleep)

  stub_request(:post, 'https://twitter.com/oauth/request_token').
    to_return(:status => "502 Bad Gateway").times(2).then.
    to_return(:body => 'oauth_token=fake&oauth_token_secret=fake')
end

Given /^getting a request token from twitter fails all the time$/ do
  Kernel.stub!(:sleep)

  stub_request(:post, 'https://twitter.com/oauth/request_token').
    to_return(:status => "502 Bad Gateway")
end

Given /^getting an access token from twitter fails twice$/ do
  Kernel.stub!(:sleep)

  stub_request(:post, 'https://twitter.com/oauth/access_token').
    to_return(:status => "502 Bad Gateway").times(2).then.
    to_return(:body => 'oauth_token=fake&oauth_token_secret=fake')
end

Given /^getting an access token from twitter fails all the time$/ do
  Kernel.stub!(:sleep)

  stub_request(:post, 'https://twitter.com/oauth/access_token').
    to_return(:status => "502 Bad Gateway")
end
