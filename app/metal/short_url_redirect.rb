# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class ShortUrlRedirect
  def self.short_url_host?(env)
    env["HTTP_HOST"] == "m2c.at" || env["QUERY_STRING"] == "short_url_host=1"
  end

  def self.call(env)
    return not_found unless short_url_host?(env)

    short_id = env['PATH_INFO'][1..-1]
    
    return redirect("/") if short_id.blank?
    
    return redirect("/products/%s" % Product.find(Base62.decode(short_id)).key)

  rescue ActiveRecord::RecordNotFound
    return not_found
  end

  def self.redirect(target)
    [
      301,
      { "Location" => "http://my2cents.mobi%s" % target,
        'Content-Type' => "text/html" },
      ["redirect"]
    ]
  end
  
  def self.not_found
    [404, {"Content-Type" => "text/html"}, ["Not Found"]]
  end
end
