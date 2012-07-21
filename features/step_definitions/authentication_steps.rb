Given /^the client_token "([^\"]*)" maps to a user named "([^\"]*)"$/ do |token, name|
  user = User.find_by_name(name) || User.make(:name => name)
  user.client_tokens.create!(:token => token)
end
