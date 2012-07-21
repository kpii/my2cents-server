class Comment < ActiveRecord::Base
  include SyncUserProducts

  belongs_to :product
  belongs_to :user

  validates_presence_of :body, :product

  before_validation_on_create :set_product_from_product_key
  after_create :touch_product

  named_scope :recent, :order => "created_at DESC", :limit => 25

  attr_writer :product_key

  serialize_with_options do
    only :id, :body, :created_at
    includes({
        :user    => {:only => [:id, :name, :profile_image_url]},
        :product => {:only => [:name, :image_url], :methods => [:key]} })
  end

  def publish_to_twitter!
    user.twitter.post("/statuses/update.json", :status => twitter_status)
  end

  def twitter_status
    appended = " | On #{product.name.first(50)} #{product.short_url}"

    available_length = 140 - appended.length

    body_for_status = if body.length > available_length
                        body.first(available_length - 3) + "..."
                      else
                        body
                      end

    [body_for_status, appended].join
  end

  def spam?
    body =~ /http(s?):\/\// && user.anonymous?
  end

protected
  def set_product_from_product_key
    if @product_key and not product
      self.product = Product.find_by_key(@product_key)
    end
  end
  
  def touch_product
    product.touch
  end
end
