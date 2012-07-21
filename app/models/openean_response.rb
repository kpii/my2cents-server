require 'open-uri'

class OpeneanResponse < ExternalResponse
  
  def get
    self.body = Iconv.iconv(
      'UTF-8','LATIN1',
      open("http://openean.kaufkauf.net/?ean=#{gtin}&cmd=query&queryid=queryid").read).
      first
    cache_attributes
  end

  def first_item
    body.split("---\n")[1]
  end
  
  def empty?
    ! first_item
  end

  def fields
    first_item.split("\n").inject({}) do |memo, line|
      if line =~ /^(.*?)=(.*)$/
        memo[$1] = $2
      end
      memo
    end
  end
  
  def name_uncached
    return nil if empty?

    if fields['name'].blank?
      fields['detailname']
    else
      fields['name']
    end
  end
  
  def image_url_uncached
    nil
  end
end
