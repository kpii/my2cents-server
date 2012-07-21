class RenameProductInfosToExternalResponses < ActiveRecord::Migration
  def self.up
    rename_table :product_infos, :external_responses
    rename_column :external_responses, :result, :body
  end

  def self.down
    rename_column :external_responses, :body, :result
    rename_table :external_responses, :product_infos
  end
end
