class MigrateProductInfosToExternalResponses < ActiveRecord::Migration
  def self.up
    %w[ AmazonUs AmazonFr AmazonUs Openean AmazonDe AmazonJp 
        Codecheck AmazonUk ].each do |base|
      ExternalResponse.update_all("type='#{base}Response'",  "type='#{base}Info'")
    end
  end

  def self.down
    %w[ AmazonUs AmazonFr AmazonUs Openean AmazonDe AmazonJp 
        Codecheck AmazonUk ].each do |base|
      ExternalResponse.update_all("type='#{base}Info'",  "type='#{base}Response'")
    end
  end
end
