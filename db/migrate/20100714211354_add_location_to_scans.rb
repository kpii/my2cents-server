class AddLocationToScans < ActiveRecord::Migration
  def self.up
    add_column :scans, :latitude, :float
    add_column :scans, :longitude, :float
  end

  def self.down
    remove_column :scans, :latitude
    remove_column :scans, :longitude
  end
end
