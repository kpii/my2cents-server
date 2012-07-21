require 'spec_helper'

module UserAgentSpecHelper
  def user_agent(value)
    request.headers['User-Agent'] = value
  end
end

describe ApplicationController, "mobile browser detection" do
  include UserAgentSpecHelper

  G1 = "Mozilla/5.0 (Linux; U; Android 1.0; en-us; dream) AppleWebKit/525.10+ (KHTML, like Gecko) Version/3.0.4 Mobile Safari/523.12.2"
  IPHONE = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"

  it "should detect android browser" do
    user_agent G1

    @controller.should be_android_browser
  end
  
  it "should detect iphone browser" do
    user_agent IPHONE
    
    @controller.should be_iphone_browser
  end
  
  it "should be mobile for iphone" do
    user_agent IPHONE
    
    @controller.should be_mobile_browser
  end

  it "should be mobile for android" do
    user_agent G1
    
    @controller.should be_mobile_browser
  end
end


describe ApplicationController, "client app detection" do
  include UserAgentSpecHelper
 
  it "should be android_client for android 1.0.4" do
    user_agent "Android my2cents [1.0.1]"
    
    @controller.should be_android_client
  end
  
  it "should not be mobile browser for android 1.0.4" do
    user_agent "Android my2cents [1.0.1]"
    
    @controller.should_not be_mobile_browser
  end
end


describe ApplicationController, "current_user" do

  it "should return anonymous user when session user_id is set but does not match existing user" do
    session[:user_id] = 12312312
    
    @controller.current_user.should be_anonymous
  end

  it "should return anonymous user when remember token is set but does not match existing user" do
    cookies[:remember_token] = "123sdsdf12312"
    
    @controller.current_user.should be_anonymous
  end
  
  it "should return user when session user_id matches existing user" do
    user = User.make
    session[:user_id] = user.id

    @controller.current_user.should == user
  end
  
  it "should return user when remember_token existing user" do
    user = User.make
    cookies[:remember_token] = user.remember_token

    @controller.current_user.should == user
  end
end
