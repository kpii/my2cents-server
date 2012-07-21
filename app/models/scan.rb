class Scan < ActiveRecord::Base

  belongs_to :user
  belongs_to :product

  attr_writer :product_key

  before_validation_on_update :set_product_from_key
  after_create :initialize_product

  named_scope :recent, :order => "scans.created_at DESC", :limit => 25

  def as_json(options={})
    options[:except] = [ 'product_id' ]
    json = super(options)
    json['scan'].merge!(product ? product.as_json : { 'product' => nil })
    json
  end

  def options_from_products
    Product.find_all_by_gtin(gtin).map do |product|
      { :product_key => product.key,
        :name => product.name,
        :image_url => product.image_url }
    end
  end

  def options
    wrap_in_product_elements(collapse_options(options_from_products))
  end

  def collapse_options(options)
    options.inject([]) do |collapsed, option|
      option_to_add = option.dup
      collapsed.each do |o|
        if o[:name] == option_to_add[:name]
          o[:source] = [o[:source], option_to_add[:source]].join(",")
          option_to_add = nil
          break
        end
      end
      collapsed << option_to_add if option_to_add
      collapsed
    end
  end
  
  def wrap_in_product_elements(things)
    things.map do |thing|
      { :product => thing }
    end
  end

protected
  def set_product_from_key
    if @product_key
      self.product = Product.find_by_key(@product_key)
    end
  end

  def best_guess
    Product.find_all_by_gtin(gtin).sort.first
  end

  def start_lookup
    ExternalResponse.get_and_cache_all_missing(gtin)
    schedule_info_monitor
  end

  def schedule_info_monitor
    self.send_at(1.second.from_now, :run_info_monitor)
  end
  
  def run_info_monitor
    logger.debug "run_info_monitor start"
    if (! ExternalResponse.requests_in_progress(gtin)) || info_monitor_timeout?
      logger.debug "run_info_monitor finished because timeout: #{info_monitor_timeout?}"
      lookup_finished
    else
      logger.debug "run_info_monitor reschedule"
      schedule_info_monitor
    end
  end

  def lookup_finished
    Product.create_missing(gtin)
    Product.make_sure_there_is_at_least_one(gtin)
    set_product
    save!
  end

  def info_monitor_timeout?
    created_at < 10.seconds.ago
  end

  def initialize_product
    set_product || start_lookup
  end
  
  def set_product
    if best_guess
      update_attribute(:product, best_guess)
      add_to_user_products
      return best_guess
    end
  end

  def add_to_user_products
    user.products << product unless user.products.include?(product)
  end
end
