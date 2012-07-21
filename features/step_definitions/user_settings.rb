Given /^the setting wants_posting_twitter is true$/ do
  @user.wants_posting_twitter = true
end

Given /^my name is "([^\"]*)"$/ do |username|
  @user.name = username
end
