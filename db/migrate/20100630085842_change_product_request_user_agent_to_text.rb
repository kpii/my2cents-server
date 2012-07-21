class ChangeProductRequestUserAgentToText < ActiveRecord::Migration
  def self.up
    change_column :product_requests, :user_agent, :text
  end

  def self.down
    change_column :product_requests, :user_agent, :string
  end
end
