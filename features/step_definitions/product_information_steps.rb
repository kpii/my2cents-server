Given /^amazon us has info about (\d+)$/ do |gtin|
  stub_request(:get, %r{^http://ecs.amazonaws.com/onca/xml\?.*ItemId=#{gtin}.*}).
    to_return(File.new(Rails.root.join('features/fixtures/amazon_lookup.http')))
end

Given /^codecheck has info about (\d+)$/ do |gtin|
  stub_request(:get, %r{^https://username:xxxxxxxxx@www.codecheck.info/WebService/rest/prod/ean/7/#{gtin}.*}).
    to_return(File.new(Rails.root.join('features/fixtures/codecheck_lookup.http')))
end

Given /^bestbuy has info about 0041333215013$/ do
  BestbuyInfo.make({
      :gtin => "0041333215013",
      :company => "Duracell",
      :brand => "Duracell",
      :gpc => "72020k000",
      :product_name => "Duracell CopperTop AA Batteries (2-Pack)",
      :product_category => "TV & Video:TV & Video Accessories",
      :model_number => "MN1500B2",
      :product_description => "Alkaline batteries; designed to provide power to radios, smoke alarms, digital audio devices and more",
      :last_update => "2010-02-06T08:31:33",
      :product_url => "http://www.bestbuy.com/site/olspage.jsp?skuId=48521&type=product&id=1185268622267&cmp=RMX",
      :image_url => "http://images.bestbuy.com/BestBuy_US/images/products/4852/48521_sc.jpg"})
end

Given /^upc_database has info about 0015300430259$/ do
  UpcDatabaseInfo.make({ 
      :gtin => "0015300430259",
      :name => "Rice A Roni, Chicken & Mushroom",
      :quantity => "5 oz"})
end

Given /^affili_net has info about 4024144500437$/ do
  AffiliNetInfo.make({ 
      :gtin => "4024144500437",
      :name => "LELO Bob Analdildo, deep blue",
      :image_url => "http://media.adultshop.de/medium/0/05004370000c.jpg"})
end

Given /^openean has info about (\d+)$/ do |gtin|
  stub_request(:get, %r{^http://openean.kaufkauf.net/\?cmd=query&queryid=149923488&ean=#{gtin}}).
    to_return(File.new(Rails.root.join("features/fixtures/openean_#{gtin}.http")))
end

Given /^there is no info on (\d+)$/ do |gtin|
  # do nothing
end

Given /^(\d+) is known as the product "([^\"]*)"$/ do |gtin, product_name|
  UpcDatabaseInfo.make({ 
      :gtin => gtin,
      :name => product_name })
end

Then /^I should see an Amazon US affiliate link$/ do

  links.any? do |link|
    link['href'] =~ /www.amazon.com/   &&
      link['href'] =~ /my2cents0f-20/  &&
      link.inner_text =~ /Amazon/
  end.should be_true
end
