class CreateCodecheckInfos < ActiveRecord::Migration
  def self.up
    create_table :codecheck_infos do |t|
      t.string :gtin, :null => false
      t.text :result
      t.timestamps
    end
    
    add_index :codecheck_infos, :gtin
  end

  def self.down
    drop_table :codecheck_infos
  end
end
