class AddScansProductId < ActiveRecord::Migration
  def self.up
    add_column :scans, :product_id, :integer
  end

  def self.down
    remove_column :scans, :product_id
  end
end
