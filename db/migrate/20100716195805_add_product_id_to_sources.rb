class AddProductIdToSources < ActiveRecord::Migration
  def self.up
    [ :external_responses, :upc_database_infos, 
      :affili_net_infos, :bestbuy_infos ].each do |table|
      add_column table, :product_id, :integer
      add_index table, :product_id
    end
  end

  def self.down
    remove_column :external_responses, :product_id
    remove_column :upc_database_infos, :product_id
    remove_column :affili_net_infos,   :product_id
    remove_column :bestbuy_infos,      :product_id
  end
end
