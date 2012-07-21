class TheController < ApplicationController
  
  def about
  end
  
  def feedback
  end

  def download
  end

  def download_notification
    DownloadNotification.create!(:email => params[:email])

    redirect_to download_path, :notice => "Thanks, you will hear from us"
  end
end
