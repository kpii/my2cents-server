class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.string :session_id
      t.integer :user_id
      t.integer :product_id, :null => false
      t.string :value, :null => false # 'up', 'down'
      t.timestamps
    end
    add_index :ratings, :user_id
    add_index :ratings, :product_id
    add_index :ratings, :session_id
  end

  def self.down
    drop_table :ratings
  end
end
