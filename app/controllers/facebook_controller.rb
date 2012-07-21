require 'facebooker'

class FacebookController < ApplicationController
  
  def login
    redirect_to "http://www.facebook.com/login.php?next=#{facebook_callback_url}&cancel=http%3A%2F%2Fmy2cents.mobi%2F&fbconnect=1&api_key=#{Facebooker.api_key}"
  end

  def callback
    fb = Facebooker::Session.create
    fb.auth_token = params[:auth_token]
    
    @user = 
      User.find_by_facebook_id(fb.user.id) ||
      User.create!({
        :name => fb.user.name,
        :facebook_id => fb.user.id,
        :facebook_auth_token => fb.auth_token,
        :profile_image_url => fb.user.pic_square})
    
    session[:user_id] = @user.id
    set_remember_token_cookie(@user.remember_token)

    authentication_succeeded 
  end
end
