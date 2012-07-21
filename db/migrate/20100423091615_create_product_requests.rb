class CreateProductRequests < ActiveRecord::Migration
  def self.up
    create_table :product_requests do |t|
      t.integer :product_id, :null => false
      t.string :session_id
      t.string :user_agent

      t.timestamp :created_at 
    end
    
    add_index :product_requests, :product_id
    add_index :product_requests, :session_id
  end

  def self.down
    drop_table :product_requests
  end
end
