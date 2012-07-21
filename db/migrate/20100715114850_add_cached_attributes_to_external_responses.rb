class AddCachedAttributesToExternalResponses < ActiveRecord::Migration
  def self.up
    add_column :external_responses, :name, :string
    add_column :external_responses, :image_url, :string
  end

  def self.down
    remove_column :external_responses, :name
    remove_column :external_responses, :image_url
  end
end
