Given /^facebook authenticates me with auth_token "([^\"]*)"$/ do |auth_token|
  stub_request(:get, %r{^http://www.facebook.com/login.php.*}).
    to_return(:status => 302, :headers => { 'Location' => "http://www.example.com/facebook/callback?auth_token=#{auth_token}" })
end

Given /^the facebook api returns user name "([^\"]*)" for auth_token "([^\"]*)"$/ do |name, auth_token|
  stub_request(:post, "http://api.facebook.com/restserver.php").
    to_return([
      { :body => File.read(Rails.root.join('features', 'fixtures', 'facebook_session.xml')) },
      { :body => File.read(Rails.root.join('features', 'fixtures', 'facebook_user.xml')) },
      { :body => File.read(Rails.root.join('features', 'fixtures', 'facebook_session.xml')) },
      { :body => File.read(Rails.root.join('features', 'fixtures', 'facebook_user.xml')) }
    ])
end
