Transform /^table:.*(?:product|user|created_at|updated_at).*$/ do |table|
  cols = table.raw.first

  table.map_column!('product') do |name|
    Product.find_by_name(name) || Product.make(:name => name)
  end if cols.include?('product')

  table.map_column!('user') do |name|
    User.find_by_name(name) || User.make(:name => name)
  end if cols.include?('user')

  %w[updated_at created_at].each do |col|
    table.map_column!(col) do |date|
      date =~ /(ago|from_now)$/ ? eval(date) : date
    end if cols.include?(col)
  end

  table
end

Given /^the following ([\w_]+) exist$/ do |model_name, table|
  model = model_name.singularize.classify.constantize

  table.hashes.each do |row|
    model.make(row)
  end
end

Given /^all products updated_at is set$/ do
  Product.update_all("updated_at=(SELECT MAX(created_at) FROM comments WHERE product_id=products.id)")
end

Given /^no .* exists$/ do
  # ok, do nothing then
end

Given /^(\d+) comments exist$/ do |count|
  product = Product.first || Product.make

  count.to_i.times do
    product.comments.make
  end
end

Given /^there is an unknown product with the key (.+)$/ do |key|
  gtin, id = key.split("-")
  Product.make(:name => nil, :id => id, :gtin => gtin)
end

Given /^the id for the next generated ([\w_]+) would be (\d+)$/ do |object, value|
  ActiveRecord::Base.connection.execute("SELECT setval('#{object}s_id_seq', #{value}, false)")
end

Given /^a product "([^"]*)" named "([^"]*)"(?: from (\w+))?$/ do |key, name, source|
  gtin, id = key.split("-")

  product = Product.make(:id => id, :gtin => gtin, :name => name)

  if source
    case source
    when "AmazonUsResponse"
      stub_request(:get, %r{^http://ecs.amazonaws.com/onca/xml\?.*ItemId=#{gtin}.*}).
        to_return(File.new(Rails.root.join('features/fixtures/amazon_lookup.http')))

      response = AmazonUsResponse.get_and_cache(gtin)
      response.update_attribute(:product, product)

    when "CodecheckResponse"
      stub_request(:get, %r{^https://username:xxxxxxxxx@www.codecheck.info/WebService/rest/prod/ean/7/#{gtin}.*}).
        to_return(File.new(Rails.root.join('features/fixtures/codecheck_lookup.http')))

      response = CodecheckResponse.get_and_cache(gtin)
      response.update_attribute(:product, product)

    when "AffiliNetResponse"
      stub_request(:get, "https://api.affili.net/V2.0/Logon.svc?wsdl").
        to_return(File.read(::Rails.root.join('features/fixtures/affili_net_logon_wsdl.http')))

      stub_request(:post, "https://api.affili.net/V2.0/Logon.svc").
        to_return(File.read(::Rails.root.join('features/fixtures/affili_net_logon.http')))

      stub_request(:get, "https://api.affili.net/V2.0/ProductServices.svc?wsdl").
        to_return(File.read(::Rails.root.join('features/fixtures/affili_net_product_services_wsdl.http')))

      stub_request(:post, "https://api.affili.net/V2.0/ProductServices.svc").
        to_return(File.read(::Rails.root.join('features/fixtures/affili_net_one_result.http')))

      response = AffiliNetResponse.get_and_cache(gtin)
      response.update_attribute(:product, product)
    else
      source.constantize.make(:gtin => gtin, :product => product)
    end
  end
end
