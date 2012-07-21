class ChangeUsersFacebookIdToBigint < ActiveRecord::Migration
  def self.up
    change_column(:users, :facebook_id, :int, :limit=> 8)
  end

  def self.down
    change_column :users, :facebook_id, :string
  end
end
