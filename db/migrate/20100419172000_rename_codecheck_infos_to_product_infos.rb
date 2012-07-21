class RenameCodecheckInfosToProductInfos < ActiveRecord::Migration
  def self.up
    rename_table :codecheck_infos, :product_infos
    add_column :product_infos, :type, :string
    ProductInfo.update_all("type='CodecheckInfo'")
  end

  def self.down
    rename_table :product_infos, :codecheck_infos
  end
end
