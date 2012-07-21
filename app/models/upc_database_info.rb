require 'csv'

class UpcDatabaseInfo < ActiveRecord::Base

  include SortedSource

  belongs_to :product

  def self.load(file_name)
    CSV::Reader.parse(File.open(file_name, 'rb')) do |values|
      create!({
          :gtin => values[0], :quantity => values[1], :name => values[2]
      })
    end
  end
  
  def self.lookup(gtin)
    find_by_gtin(gtin)
  end

  # Mimic interface from other ProductInfo classes
  def result
    attributes
  end

  def created_at
  end

  def found?
    true
  end

  def image_url
    nil
  end
end
