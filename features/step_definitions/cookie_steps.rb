# Monkey patch rack test to support clearing only cookies that are not
# persistent
Rack::Test::Session.class_eval do
  def_delegators :@rack_mock_session, :clear_non_persistent_cookies
end

Rack::MockSession.class_eval do
  def clear_non_persistent_cookies
    @cookie_jar.clear_non_persistent_cookies
  end
end

Rack::Test::CookieJar.class_eval do
  def clear_non_persistent_cookies
    @cookies.reject! { |cookie| cookie.expires.nil? }
  end
end

When /^I start a new browser session$/ do
  Capybara.reset_sessions!
end

When /^I keep the permanent cookies and start a new browser session$/ do
  Capybara.current_session.driver.current_session.clear_non_persistent_cookies
end

Then /^I should receive a "([^\"]*)" cookie$/ do |key|
  @cookies = response.cookies
  @cookies[key].should_not be_nil
end

When /^I include the "([^\"]*)" cookie$/ do |key|
  # I wish I knew how to clear all cookies and only send the one
  # specified here
end

Given /^I include the cookie "([^\"]*)" with value "([^\"]*)" in every request$/ do |key, value|
  # Note that this affects the integration test session
  # (get|post|put|delete), not the capybara session (visit).
  cookies[key] = value
end

When /^I clear all cookies$/ do
  # Note that this affects the integration test session
  # (get|post|put|delete), not the capybara session (visit).
  cookies.clear
end
