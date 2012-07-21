module TwitterAuth
  module OauthUser
    def self.included(base)
      base.class_eval do
        attr_protected :access_token, :access_secret
      end

      base.extend TwitterAuth::OauthUser::ClassMethods
      base.extend TwitterAuth::Dispatcher::Shared
    end
    
    module ClassMethods
      def authenticate_user_with_access_token(user, token)
        
        response = token.get(TwitterAuth.path_prefix + '/account/verify_credentials.json')
        user_info = handle_response(response)
        
        if existing_user = User.find_by_twitter_id(user_info['id'].to_s)
          # A user with that login exists, migrate current data to this user
          [Comment, Scan, Rating, ClientToken].each do |klass|
            klass.update_all("user_id=#{existing_user.id}", ["user_id=?", user.id])
          end
          user.destroy

          existing_user.twitter_login = user_info['screen_name']
          existing_user.name = user_info['name']
          existing_user.profile_image_url = user_info['profile_image_url']
          existing_user.twitter_access_token = token.token
          existing_user.twitter_access_secret = token.secret
          existing_user.save!
          existing_user
        else
          # Use the user that was passed in
          user.twitter_id = user_info['id'].to_s
          user.twitter_login = user_info['screen_name']

          user.name = user_info['name']
          user.profile_image_url = user_info['profile_image_url']
          user.save!

          user
        end
      end
    end

    def token
      OAuth::AccessToken.new(TwitterAuth.consumer, access_token, access_secret)
    end 
  end
end
