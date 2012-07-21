class MeController < ApplicationController
  
  def show
    render :json => { 
      :me => { 
        :name => current_user.name,
        :profile_image_url => current_user.profile_image_url } }
  end
end
