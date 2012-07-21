class CreateUserProvidedInfo < ActiveRecord::Migration
  def self.up
    create_table :user_provided_infos do |t|
      t.string :gtin, :null => false
      t.string :name, :null => false
      t.integer :user_id
    end
    
    add_index :user_provided_infos, :gtin
  end

  def self.down
    drop_table :user_provided_infos
  end
end
