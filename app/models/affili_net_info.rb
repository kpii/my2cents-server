# Database storage for affili.net info. 
class AffiliNetInfo < ActiveRecord::Base

  include SortedSource

  belongs_to :product

  # Mimic interface from other ProductInfo classes
  def result
    attributes
  end

  def created_at
  end

  def found?
    true
  end
end
