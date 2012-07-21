class CreateUpcDatabaseInfos < ActiveRecord::Migration
  def self.up
    create_table :upc_database_infos do |t|
      t.string :gtin
      t.string :name
      t.string :quantity
    end
    
    add_index :upc_database_infos, :gtin
  end

  def self.down
    remove_table :upc_database_infos
  end
end
