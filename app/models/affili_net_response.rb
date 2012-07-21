class AffiliNetResponse < ExternalResponse
require "savon"

  serialize :body

  def get_token
    logon_url = "https://api.affili.net/V2.0/Logon.svc?wsdl"
    username = 'username'
    password = 'xxxxxxxxxxxxxxxxxxxx'

    client = Savon::Client.new logon_url
    Savon::Request.log=false

    logon_result = client.logon { |soap|
                    soap.body = {
                            "ns1:Username" => username,
                            "ns1:Password" => password,
                            "ns1:WebServiceType" => "Product",
                            :order! => ["ns1:Username","ns1:Password","ns1:WebServiceType"]
                    }
                    soap.namespaces["xmlns:ns1"] = "http://affilinet.framework.webservices/types"
                    soap.input = "LogonRequestMsg"
    }
    token = logon_result.to_hash[:credential_token]
  end

  def get
    token = get_token
    product_url = "https://api.affili.net/V2.0/ProductServices.svc?wsdl"

    client = Savon::Client.new product_url
    Savon::Request.log=false

    self.body = client.search_products { |soap|
                    soap.body = {
                            "wsdl:CredentialToken" => token,
                            "wsdl:SearchProductsRequestMessage" => {
                                  'ns2:ShopIds' => '',
                                  'ns2:Query' => gtin,
                                  'ns2:WithImageOnly' => 'false',
                                  'ns2:Details' => 'false',
                                  'ns2:ImageSize' => 'AllImages',
                                  'ns2:CurrentPage' => '1',
                                  'ns2:PageSize' => '10',
                                  'ns2:MinimumPrice' => '0',
                                  'ns2:MaximumPrice' => '0',
                                  'ns2:SortBy' => 'Rank',
                                  'ns2:SortOrder' => 'Ascending',
                                  :order! => ['ns2:ShopIds','ns2:Query','ns2:WithImageOnly','ns2:Details','ns2:SortOrder','ns2:CurrentPage','ns2:PageSize','ns2:MinimumPrice','ns2:MaximumPrice','ns2:SortBy','ns2:ImageSize']
                            },
                            :order! => ["wsdl:CredentialToken","wsdl:SearchProductsRequestMessage"]
                    }
                    soap.namespaces["xmlns:ns2"] = "http://affilinet.framework.webservices/types/ProductService"
                    soap.input = "SearchProductsRequest"
    }.to_hash[:product_search_result]

    cache_attributes
  end

  def name_uncached
    if body[:records] == "0"
      return nil
    elsif body[:records] == "1"
      return body[:products][:product][:title]
    elsif body[:records].to_i > 1
      return body[:products][:product][0][:title]
    end
  end

  def image_url_uncached
    if body[:records] == "0"
      return nil
    elsif body[:records] == "1"
      return body[:products][:product][:image90][:image_url]
    elsif body[:records].to_i > 1
      return body[:products][:product][0][:image90][:image_url]
    end
  end

  def url
    if body[:records] == "0"
      return nil
    elsif body[:records] == "1"
      return body[:products][:product][:deep_link1]
    elsif body[:records].to_i > 1
      return body[:products][:product][0][:deep_link1]
    end
  end

  def shopname
    if body[:records] == "0"
      return nil
    elsif body[:records] == "1"
      return body[:products][:product][:shop_information][:shop_name]
    elsif body[:records].to_i > 1
      return body[:products][:product][0][:shop_information][:shop_name]
    end
  end


  def more
    [
      ['Subtitle', 'subtit'],
      ['Category', 'catName'],
      ['Manufacturer', 'gs1Manu'],
      ['Quantity', 'quant'],
    ].map do |title, key|
      [title, body['result'][key]]
    end
  end

end
