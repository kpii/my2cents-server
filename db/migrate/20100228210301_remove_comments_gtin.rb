class RemoveCommentsGtin < ActiveRecord::Migration
  def self.up
    remove_column :comments, :gtin
  end

  def self.down
    add_column :comments, :gtin, :integer
  end
end
