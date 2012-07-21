class ExternalResponse < ActiveRecord::Base
  include SortedSource

  belongs_to :product

  def self.get_and_cache_all_missing(gtin)
    types.each do |klass|
      klass.send_later(:get_and_cache, gtin) unless klass.exists?(:gtin => gtin)
    end
  end

  def self.types
    [ AmazonDeResponse, AmazonUsResponse, AmazonUkResponse, AmazonJpResponse, 
      AmazonFrResponse, CodecheckResponse, OpeneanResponse, AffiliNetResponse ]
  end

  def self.complete_for?(gtin)
    find(:all, :conditions => { :gtin => gtin }).map(&:type).uniq.sort ==
      types.map(&:to_s).sort
  end

  def self.get_and_cache(gtin)
    raise "Call this on subclasses only" if self == ExternalResponse

    response = new(:gtin => gtin)
    response.get
    response.save!
    response
  end
  
  def self.find_all_found(gtin)
    find(:all, :conditions => ["name IS NOT NULL AND gtin=?", gtin])
  end

  def self.requests_in_progress(gtin)
    Delayed::Job.exists?(
      [ "last_error IS NULL AND handler LIKE '%method: :get_and_cache%' || ? || '%'",
        gtin])
  end

  def cache_attributes
    self.name = name_uncached.andand.first(255)
    self.image_url = image_url_uncached.andand.first(255)
  end
  
  def found?
    !! name
  end
end
