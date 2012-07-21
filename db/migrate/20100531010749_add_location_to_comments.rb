class AddLocationToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :latitude, :float
    add_column :comments, :longitude, :float
  end

  def self.down
    remove_column :comments, :latitude
    remove_column :comments, :longitude
  end
end
