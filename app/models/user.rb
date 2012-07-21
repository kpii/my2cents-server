class User < ActiveRecord::Base

  include TwitterAuth::OauthUser

  has_many :comments
  has_many :commented_products, :source => :product, :through => :comments, :uniq => true
  has_many :ratings
  has_many :scans, :conditions => "product_id IS NOT NULL"
  has_many :client_tokens
  has_and_belongs_to_many :products

  before_validation_on_create :set_remember_token

  def self.new_from_twitter_hash(hash)
    raise ArgumentError, 'Invalid hash: must include screen_name.' unless hash.key?('screen_name')

    raise ArgumentError, 'Invalid hash: must include id.' unless hash.key?('id')

    user = User.new
    user.twitter_id = hash['id'].to_s
    user.twitter_login = hash['screen_name']

    user.name = hash['name']
    user.profile_image_url = hash['profile_image_url']

    user
  end

  def self.from_remember_token(token)
    first(:conditions => ["remember_token = ?", token])
  end

  def self.from_client_token(token)
    ClientToken.find(:first, :conditions => ["token=?", token]).andand.user
  end

  def name
    attributes['name'] || 'Anonymous'
  end

  def profile_image_url
    attributes['profile_image_url'] || "http://#{DEFAULT_HOST}/images/anonymous.png?4"
  end

  def anonymous?
    ! attributes['name']
  end

  def twitter
    TwitterAuth::Dispatcher::Oauth.new(self)
  end

  def profile_url
    case
    when twitter_id
      "http://twitter.com/#{twitter_login}"
    when facebook_id
      "http://www.facebook.com/profile.php?id=#{facebook_id}"
    end
  end
  
  def profile_url_source
    case
    when twitter_id
      "Twitter"
    when facebook_id
      "Facebook"
    end
  end

  def admin?
    twitter_id && ["user1", "user2"].include?(twitter_login)
  end

  def has_seen?(event)
    inbox_seen_at && (inbox_seen_at > event.created_at)
  end

  def owns?(thing)
    thing.user == self
  end

protected

  def set_remember_token
    self.remember_token ||= ActiveSupport::SecureRandom.hex(10)
  end
end
