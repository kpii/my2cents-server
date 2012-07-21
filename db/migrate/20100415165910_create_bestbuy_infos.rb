class CreateBestbuyInfos < ActiveRecord::Migration
  def self.up
    create_table :bestbuy_infos do |t|
      t.string :gtin 
      t.string :company 
      t.string :brand 
      t.string :gpc 
      t.string :product_name 
      t.string :product_category 
      t.string :model_number 
      t.string :product_description 
      t.string :last_update 
      t.string :product_url 
      t.string :image_url 
    end
    
    add_index :bestbuy_infos, :gtin
  end

  def self.down
    drop_table :bestbuy_infos
  end
end
