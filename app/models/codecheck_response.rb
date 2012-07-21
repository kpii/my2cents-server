require 'wrest'

class CodecheckResponse < ExternalResponse

  serialize :body

  def self.uri(gtin)
    "https://www.codecheck.info/WebService/rest/prod/ean/7/#{gtin}".
      to_uri(:username => "username", :password => "xxxxxxxxx")
  end
  
  def get
    self.body = CodecheckResponse.uri(gtin).get.deserialise
    cache_attributes
  end

  def image_id
    body["result"].andand["imgId"]
  end

  def name_uncached
    body["result"].andand["name"]
  end

  def image_url_uncached
    "http://www.codecheck.info/img/#{image_id}/2" if image_id
  end

  def codecheck_id
    body["result"]["id"]
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

  def url
    "http://www.codecheck.info/id_#{codecheck_id}/product.pro"
  end
end
