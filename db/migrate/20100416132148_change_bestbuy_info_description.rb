class ChangeBestbuyInfoDescription < ActiveRecord::Migration
  def self.up
    change_column :bestbuy_infos, :product_description, :text
  end

  def self.down
    change_column :bestbuy_infos, :product_description, :string
  end
end
