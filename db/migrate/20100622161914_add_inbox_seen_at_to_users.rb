class AddInboxSeenAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :inbox_seen_at, :datetime
  end

  def self.down
    remove_column :users, :inbox_seen_at
  end
end
