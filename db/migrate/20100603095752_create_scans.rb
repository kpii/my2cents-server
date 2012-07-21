class CreateScans < ActiveRecord::Migration
  def self.up
    create_table :scans do |t|
      t.string :gtin, :null => false
      t.integer :user_id
      t.timestamps
    end
    
    add_index :scans, :gtin
  end

  def self.down
    drop_table :scans
  end
end
