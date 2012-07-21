class CreateClientTokens < ActiveRecord::Migration
  def self.up
    create_table :client_tokens do |t|
      t.string :token, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
    
    add_index :client_tokens, :token, :unique => true
    add_index :client_tokens, :user_id
  end

  def self.down
    drop_table :client_tokens
  end
end
