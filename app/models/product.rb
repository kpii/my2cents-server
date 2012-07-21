class Product < ActiveRecord::Base

  KEY_FORMAT = '[0-9-]+'
  INFO_TIMEOUT = 8   # seconds

  has_many :scans
  has_many :comments, :order => "created_at DESC"
  has_many :ratings

  before_validation :truncate_name

  def self.create_missing(gtin)
    ( ExternalResponse.find_all_found(gtin) +
      UpcDatabaseInfo.find_all_by_gtin(gtin) +
      AffiliNetInfo.find_all_by_gtin(gtin) +
      BestbuyInfo.find_all_by_gtin(gtin)
    ).each do |source|

      product = find(:first, :conditions => { :gtin => gtin, :name => source.name}) ||
        create!(:gtin => gtin, :name => source.name, :image_url => source.image_url)

      source.update_attribute(:product, product)
    end
  end

  def self.make_sure_there_is_at_least_one(gtin)
    unless Product.exists?(:gtin => gtin)
      Product.create!(:gtin => gtin, :name => nil, :image_url => nil)
    end
  end

  def self.find_by_key(key)
    Product.find(key.split("-").last.to_i)
  end

  def self.find_by_key!(key)
    find_by_key(key) or raise ActiveRecord::RecordNotFound
  end

  def sources
    ( ExternalResponse.find_all_by_product_id(id) +
      UpcDatabaseInfo.find_all_by_product_id(id) +
      AffiliNetInfo.find_all_by_product_id(id) +
      BestbuyInfo.find_all_by_product_id(id) )
  end

  def codecheck_source
    CodecheckResponse.find(:first, 
      :conditions => { :product_id => self.id },
      :order => "created_at DESC")
  end

  def amazon_source
    AmazonResponse.find(:first, 
      :conditions => { :product_id => self.id },
      :order => "created_at DESC")
  end

  def affili_source
    AffiliNetResponse.find(:first, 
      :conditions => { :product_id => self.id },
      :order => "created_at DESC")
  end


  def as_json(options={})
    opts = options.dup
    opts[:methods] ||= [ 'key' ]
    opts[:except] = [ 'id' ]
    super(opts)
  end
  
  def as_detailed_json
    as_json(
      :only => [:name, :image_url],
      :include => {
        :comments => 
        { :only    => [:id, :body, :created_at],
          :include => { :user => { :only => [ :id, :name, :profile_image_url ] } } } },
      :methods => [ :key, :affiliate_links, :affiliates ])
  end

  def to_param
    key
  end

  def key
    "#{gtin}-#{id}"
  end

  def short_url
    "http://m2c.at/#{Base62.encode(id)}"
  end

  # This is deprecated and should not be used by newer clients anymore
  def affiliate_links
    affiliates.map { |a| a[:href] }
  end

  def affiliates
    links = []
    links << { :href => codecheck_source.url, :text => 'Codecheck' } if codecheck_source
    links << { :href => amazon_source.url, :text => 'Amazon' } if amazon_source
    links << { :href => affili_source.url, :text => affili_source.shopname } if affili_source
    links
  end

  def all_jobs_finished?
    @jobs.blank? ||
      ! Delayed::Job.exists?(["id IN (?)", @jobs.map(&:id)])
  end

  def name
    attributes['name'] || "Unknown Product (#{gtin})"
  end

  def info_available?
    !! attributes['name']
  end

  def unknown?
    ! info_available?
  end

  def wait_for_infos
    # Warning: don't use ActiveSupport::Duration for timeout and
    # sleep!
    begin
      Timeout.timeout(INFO_TIMEOUT) do
        until info_available? || all_jobs_finished? do
          Kernel.sleep 1
          Product.uncached { reload }
        end
      end
    rescue Timeout::Error
      logger.warn "[#{Time.now}] A timeout occured getting infos for product: #{id}"
    end

    Product.uncached { reload }
    return self
  end

  def rate!(options)
    ratings.find_by_user_id(options[:user]).andand.destroy

    if options[:value].blank?
      ratings.new
    else
      ratings.create!(options)
    end
  end

  def <=>(other)
    return -1 if user_updated_at
    return 1 if other.user_updated_at
    sources.sort.first <=> other.sources.sort.first if sources and other.sources
  end

protected

  def truncate_name
    if name.length > 255
      self.name = name.first(255)
    end
  end
end
