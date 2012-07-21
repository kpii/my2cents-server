class CreateDownloadNotification < ActiveRecord::Migration
  def self.up
    create_table :download_notifications do |t|
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :download_notifications
  end
end
