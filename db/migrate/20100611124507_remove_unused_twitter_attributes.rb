class RemoveUnusedTwitterAttributes < ActiveRecord::Migration
  def self.up
    rename_column :users, :login, :twitter_login
    rename_column :users, :access_token, :twitter_access_token
    rename_column :users, :access_secret, :twitter_access_secret
    
    remove_column :users, :remember_token_expires_at

    remove_column :users, :location
    remove_column :users, :description
    remove_column :users, :url
    remove_column :users, :protected
    remove_column :users, :profile_background_color
    remove_column :users, :profile_sidebar_fill_color
    remove_column :users, :profile_link_color
    remove_column :users, :profile_sidebar_border_color
    remove_column :users, :profile_text_color
    remove_column :users, :profile_background_image_url
    remove_column :users, :profile_background_tiled
    remove_column :users, :friends_count
    remove_column :users, :statuses_count
    remove_column :users, :followers_count
    remove_column :users, :favourites_count
    remove_column :users, :utc_offset
    remove_column :users, :time_zone
  end

  def self.down
    rename_column :users, :twitter_login, :login
    rename_column :users, :twitter_access_token, :access_token
    rename_column :users, :twitter_access_secret, :access_secret
    
    add_column :users, :remember_token_expires_at, :datetime

    add_column :users, :location, :string
    add_column :users, :description, :string
    add_column :users, :url, :string
    add_column :users, :protected, :string
    add_column :users, :profile_background_color, :string
    add_column :users, :profile_sidebar_fill_color, :string
    add_column :users, :profile_link_color, :string
    add_column :users, :profile_sidebar_border_color, :string
    add_column :users, :profile_text_color, :string
    add_column :users, :profile_background_image_url, :string
    add_column :users, :profile_background_tiled, :string
    add_column :users, :friends_count, :integer
    add_column :users, :statuses_count, :integer
    add_column :users, :followers_count, :integer
    add_column :users, :favourites_count, :integer
    add_column :users, :utc_offset, :integer
    add_column :users, :time_zone, :string
  end
end
