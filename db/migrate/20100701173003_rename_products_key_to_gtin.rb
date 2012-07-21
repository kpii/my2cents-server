class RenameProductsKeyToGtin < ActiveRecord::Migration
  def self.up
    rename_column :products, :key, :gtin
  end

  def self.down
    rename_column :products, :gtin, :key
  end
end
