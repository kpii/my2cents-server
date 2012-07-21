class RenameGtinToKey < ActiveRecord::Migration
  def self.up
    rename_column :products, :gtin, :key
  end

  def self.down
    rename_column :products, :key, :gtin
  end
end
