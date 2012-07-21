require 'spec_helper'

describe ShortUrlRedirect, "when host is not the short url host" do
  before(:each) do
    @env = {}
    @env["HTTP_HOST"] = "my2cents.mobi"
    @env['PATH_INFO'] = "/"
  end

  it "should return 404 not found" do
    status, headers, content = ShortUrlRedirect.call(@env)

    status.should == 404
  end
end


describe ShortUrlRedirect, "for a product" do
  before(:each) do
    @product = Product.make

    @env = {}
    @env["HTTP_HOST"] = "m2c.at"
    @env['PATH_INFO'] = "/#{Base62.encode(@product.id)}"
  end
  
  it "should redirect to product page" do
    status, headers, content = ShortUrlRedirect.call(@env)
    
    status.should == 301
    headers['Location'].should == "http://my2cents.mobi/products/#{@product.key}"
  end
end


describe ShortUrlRedirect, "for an unknown URL" do
  before(:each) do
    @env = {}
    @env["HTTP_HOST"] = "m2c.at"
    @env['PATH_INFO'] = "/huba"
  end
  
  it "should return 404 Not Found" do
    status, headers, content = ShortUrlRedirect.call(@env)
    
    status.should == 404
  end
end


describe ShortUrlRedirect, "for the root page" do
  before(:each) do
    @env = {}
    @env["HTTP_HOST"] = "m2c.at"
    @env['PATH_INFO'] = '/'
  end
  
  it "should redirect to root page" do
    status, headers, content = ShortUrlRedirect.call(@env)
    
    status.should == 301
    headers['Location'].should == "http://my2cents.mobi/"
  end
end
