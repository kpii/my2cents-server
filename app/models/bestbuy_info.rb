# A table with imported data
#
# It has the following attributes
#
# GTIN,Company,Brand,GPC,ProductName,ProductCategory,ModelNumber,
# ProductDescription,LastUpdate,ProductURL,ImageURL
#
# mapped to lowercase, e.g. "product_url"
#
# Here's how to import it from csv into a postgresql database:
#
# my2cents_production=# set client_encoding = latin1;
# my2cents_production=# copy bestbuy_infos (gtin, company, brand, gpc, product_name, product_category, model_number, product_description, last_update, product_url, image_url) from 'bestbuy_products.csv' csv quote as '"';

require 'csv'

class BestbuyInfo < ActiveRecord::Base

  include SortedSource

  belongs_to :product

  def self.lookup(gtin)
    find_by_gtin(gtin)
  end

  # Load from a csv file. Only useful for development subset, it's too
  # slow for the whole 1M dataset
  def self.load(file_name)
    CSV::Reader.parse(File.open(file_name, 'rb')) do |values|
      create!({
          :gtin => values[0], :company => values[1], :brand => values[2],
          :gpc => values[3], :product_name => values[4], :product_category => values[5],
          :model_number => values[6], :product_description => values[7],
          :last_update => values[8], :product_url => values[9], :image_url => values[10]
        })
    end
  end

  def name
    product_name
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
end
