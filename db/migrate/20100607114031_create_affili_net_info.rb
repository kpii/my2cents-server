class CreateAffiliNetInfo < ActiveRecord::Migration
  def self.up
    create_table :affili_net_infos do |t|
      t.string :gtin
      t.string :name
      t.string :image_url
    end
    
    add_index :affili_net_infos, :gtin
  end

  def self.down
    drop_table :affili_net_infos
  end
end
