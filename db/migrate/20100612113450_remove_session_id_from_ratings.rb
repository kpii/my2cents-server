class RemoveSessionIdFromRatings < ActiveRecord::Migration
  def self.up
    remove_column :ratings, :session_id
  end

  def self.down
    add_column :ratings, :session_id, :string
    add_index :ratings, :session_id
  end
end
