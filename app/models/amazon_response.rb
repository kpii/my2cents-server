require 'amazon/aws'
require 'amazon/aws/search'

class AmazonResponse < ExternalResponse
  include Amazon::AWS
  include Amazon::AWS::Search

  serialize :body

  def get
    il = ItemLookup.new('EAN', { 'ItemId' => gtin, 'SearchIndex' => 'All'})
    rg = ResponseGroup.new('Medium')
    req = Request.new
    req.locale = locale
    self.body = req.search(il, rg)

    cache_attributes
  rescue => e
    if e.class.to_s =~ /^Amazon::AWS::Error.*/
      # AWS Error - assume it is transient
      logger.warn "amazon error: #{e.inspect}"
      return nil
    else
      raise
    end
  end
  
  def locale
    self.class.to_s =~ /^Amazon(..)Response$/
    $1.downcase
  end

  # aaws requires us to call its own yaml load becaus it dynamically
  # defines aws classes (meh). There is no spec for this because I
  # don't know how to simulate a situation with non-declared classes -
  # test it in a fresh started console.
  def object_from_yaml(string)
    return string unless string.is_a?(String) && string =~ /^---/
    Amazon::AWS::AWSObject.yaml_load(StringIO.new(string))
  end

  def image_url_uncached
    return nil unless has_single_item?
    body.item_lookup_response.items.item.small_image.andand.url.andand.to_s
  end

  def name_uncached
    return nil unless has_single_item?
    body.item_lookup_response.items.item.item_attributes.andand do |item_attributes|
      (item_attributes.title || item_attributes.label).to_s
    end
  end
  
  def has_single_item?
    !!body && body.item_lookup_response.items.item.size == 1
  end

  def url
    body.item_lookup_response.items.item.detail_page_url.to_s
  end
end


# Make sure that all subclasses are loaded. Otherwise a query like
# AmazonResponse.find doesn't do the right thing. Unfortunately this
# is not spec-able.
%w[ us de fr jp uk ].each do |locale|
  require_dependency "amazon_#{locale}_response"
end
