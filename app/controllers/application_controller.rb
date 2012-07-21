# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  class Forbidden  < StandardError; end
  class BadRequest < StandardError; end

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :validate_client_token_length

  rescue_from Forbidden, :with => :forbidden
  rescue_from BadRequest, :with => :bad_request

  def android_browser?
    request.headers['User-Agent'] =~ /android/i &&
      ! android_client?
  end
  helper_method :android_browser?

  def iphone_browser?
    request.headers['User-Agent'] =~ /iphone/i
  end

  def mobile_browser?
    android_browser? || iphone_browser?
  end
  helper_method :mobile_browser?
  
  def android_client?
    !! ( request.headers['User-Agent'] =~ /^Android my2cents/ )
  end

  def iphone_client?
    !! ( request.headers['User-Agent'] =~ /^my2cents.*Darwin/ )
  end

  def client_app?
    android_client? || iphone_client?
  end

  def admin?
    logged_in? && current_user.admin?
  end
  helper_method :admin?

  def logged_in_with_twitter?
    logged_in? && current_user.twitter_id
  end
  helper_method :logged_in_with_twitter?
  
  def require_admin
    raise Forbidden unless admin?
  end
  
  helper_method :current_user, :logged_in?

  def forbidden
    render :text => "Forbidden", :status => :forbidden
  end

  def bad_request(e)
    render :text => "Bad Request: #{e.message}", :status => :bad_request
  end

  def authentication_succeeded
    flash[:notice] = "Logged in successfully"
    if android_client? || android_browser?
      redirect_to '/auth/success'
    else
      redirect_to '/'
    end
  end
  
  def authentication_failed(message)
    flash[:error] = message
    redirect_to '/auth/failure'
  end

  def current_user
    @current_user ||= (if using_client_token?
                         User.from_client_token(cookies[:client_token])
                       else
                         ( session[:user_id] && User.find_by_id(session[:user_id]) ||
                           cookies[:remember_token] && User.from_remember_token(cookies[:remember_token]))
                       end) || User.new
  end

  def ensure_current_user_is_saved
    if current_user.new_record?
      current_user.save!

      if using_client_token?
        current_user.client_tokens.create!(:token => cookies[:client_token])
      else
        session[:user_id] = current_user.id
      end
    end
  end

  def logged_in?
    ! current_user.anonymous?
  end

  def set_remember_token_cookie(token)
    cookies[:remember_token] = { :value => token, :expires => 20.years.from_now }
  end
  
  def using_client_token?
    !! cookies[:client_token]
  end
  
  def validate_client_token_length
    if using_client_token?
      raise BadRequest.new("client_token value is too short") if cookies[:client_token].size < 10
    end
  end
end
