class SetNameOfProducts < ActiveRecord::Migration
  def self.up
    Product.find_each do |product|
      product.send(:make_sure_name_is_set)
      product.save!
    end
  end

  def self.down
  end
end
