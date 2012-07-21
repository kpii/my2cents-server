class AddProductsUserUpdatedAtRemoveUserProvidedInfo < ActiveRecord::Migration
  def self.up
    add_column :products, :user_updated_at, :datetime
    
    drop_table :user_provided_infos
  end

  def self.down
    remove_column :products, :user_updated_at, :datetime
    
    create_table "user_provided_infos", :force => true do |t|
      t.string  "gtin",    :null => false
      t.string  "name",    :null => false
      t.integer "user_id"
    end

    add_index "user_provided_infos", ["gtin"], :name => "index_user_provided_infos_on_gtin"
  end
end
