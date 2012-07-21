Given /^I am logged in as admin$/ do
  Given 'twitter would authenticate me'
  And 'my twitter name is "user1"'
  When 'I go to the root page'
  And 'I follow "Login with Twitter"'
end
