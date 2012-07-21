class SessionsController < ApplicationController

  def new
    retry_a_couple_of_times do
      oauth_callback = request.protocol + request.host_with_port + '/oauth_callback'
      @request_token = TwitterAuth.consumer.get_request_token({:oauth_callback=>oauth_callback})

      if params[:client_token]
        user = User.from_client_token(params[:client_token])
        if user.nil?
          user = User.create!
          user.client_tokens.create!(:token => params[:client_token])
        end
        session[:user_id] = user.id
        session[:remember_token] = nil
      end

      session[:request_token] = @request_token.token
      session[:request_token_secret] = @request_token.secret

      url = @request_token.authorize_url
      url << "&oauth_callback=#{CGI.escape(TwitterAuth.oauth_callback)}" if TwitterAuth.oauth_callback?

      redirect_to url
    end
  end

  def oauth_callback
    retry_a_couple_of_times do
      begin
        unless session[:request_token] && session[:request_token_secret] 
          authentication_failed('No authentication information was found in the session. Please try again.') and return
        end

        # We changed this from the twitterauth implementation to not
        # accept an empty params[:oauth_token] anymore. Not sure if oauth
        # is supposed to work with calling the callback without that
        # param. We need to detect twitters denied=... param.
        unless session[:request_token] == params[:oauth_token]
          authentication_failed('Authentication information does not match session information. Please try again.') and return
        end

        @request_token = OAuth::RequestToken.new(TwitterAuth.consumer, session[:request_token], session[:request_token_secret])

        @access_token = @request_token.get_access_token(:oauth_verifier => params["oauth_verifier"])

        ensure_current_user_is_saved

        @user = User.authenticate_user_with_access_token(current_user, @access_token)

        # The request token has been invalidated
        # so we nullify it in the session.
        session[:request_token] = nil
        session[:request_token_secret] = nil

        unless using_client_token?
          session[:user_id] = @user.id
          set_remember_token_cookie(@user.remember_token)
        end

        authentication_succeeded 
      rescue Net::HTTPServerException => e
        case e.message
        when '401 "Unauthorized"'
          authentication_failed('This authentication request is no longer valid. Please try again.') and return
        else
          authentication_failed('There was a problem trying to authenticate you. Please try again.') and return
        end
      end
    end
  end
  
  def destroy
    @current_user = nil
    cookies.delete(:remember_token)
    reset_session

    redirect_to root_path
  end

  def success
  end
  
  def failure
  end
  
protected

  def retry_a_couple_of_times(&block)
    yield
  rescue => e
    @retries ||= 0
    
    if @retries < 2
      @retries += 1
      Kernel.sleep 1
      retry
    else
      logger.warn("[#{Time.now}] Twitter authentication failed: #{e.message}\n  #{clean_backtrace(e).join("\n  ")}")
      authentication_failed("Sorry, there seems to be an error with the Twitter API. Please retry. If the problem persists we will look into it.")
    end
  end
end
