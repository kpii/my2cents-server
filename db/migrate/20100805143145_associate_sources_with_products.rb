class AssociateSourcesWithProducts < ActiveRecord::Migration
  def self.up
    ExternalResponse.all.each do |external_response|
      puts "updating external_response #{external_response.class} #{external_response.id}"
      external_response.cache_attributes
      external_response.save! if external_response.name
    end

    Product.all.each do |product|
      [ ExternalResponse, UpcDatabaseInfo, AffiliNetInfo, BestbuyInfo ].each do |klass|
        klass.find(:all, 
          :conditions => { :gtin => product.gtin, :name => product.name }).each do |source|
          puts "updating source #{source.class} #{source.id}"
          source.update_attribute(:product, product)
        end
      end
    end
  end

  def self.down
    # no-op
  end
end
