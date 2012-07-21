class CreateProductsUsers < ActiveRecord::Migration
  def self.up
    create_table :products_users, :id => false do |t|
      t.integer :product_id, :null => false
      t.integer :user_id, :null => false
    end
    
    add_index :products_users, [:product_id, :user_id], :unique => true
  end

  def self.down
    drop_table :products_users
  end
end
