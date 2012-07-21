require 'spec_helper'

def stub_logon
    stub_request(:get, "https://api.affili.net/V2.0/Logon.svc?wsdl").
      to_return(File.read(::Rails.root.join('features/fixtures/affili_net_logon_wsdl.http')))

    stub_request(:post, "https://api.affili.net/V2.0/Logon.svc").
      to_return(File.read(::Rails.root.join('features/fixtures/affili_net_logon.http')))
end

def stub_product_services_wsdl
    stub_request(:get, "https://api.affili.net/V2.0/ProductServices.svc?wsdl").
      to_return(File.read(::Rails.root.join('features/fixtures/affili_net_product_services_wsdl.http')))
end

describe AffiliNetResponse, "get token" do
  before(:each) do
    stub_logon

    @info = AffiliNetResponse.new
    @token = @info.get_token
  end

  it "should have a token" do
    @token.should == "4ef2c382-7081-4da1-96ee-49a6a2f2f27a"
  end
end

describe AffiliNetResponse, "found one result" do
  before(:each) do
    @gtin = "9783462040449"
    stub_logon
    stub_product_services_wsdl

    stub_request(:post, "https://api.affili.net/V2.0/ProductServices.svc").
      to_return(File.read(::Rails.root.join('features/fixtures/affili_net_one_result.http')))

    @info = AffiliNetResponse.new(:gtin => @gtin)
    @info.get
  end

  it "should extract name" do
    @info.name_uncached.should == "Tiere Essen"
  end

  it "should return true for found" do
    @info.should be_found
  end

  it "should have a name" do
    @info.name.should == "Tiere Essen"
  end

  it "should have a image_url" do
    @info.image_url.should == "http://images90.affili.net/404.gif"
  end

  it "should have a url" do
    @info.url.should == "http://partners.webmasterplan.com/click.asp?ref=524680&site=3780&type=text&tnb=12&subid=&diurl=http://www.buecher.de/29441811/wea/1160015"
  end

  it "should have a shopname" do
    @info.shopname.should == "buecher.de - Topseller"
  end
end

describe AffiliNetResponse, "found two results" do
  before(:each) do
    @gtin = "9783462040449"
    stub_logon
    stub_product_services_wsdl

    stub_request(:post, "https://api.affili.net/V2.0/ProductServices.svc").
      to_return(File.read(::Rails.root.join('features/fixtures/affili_net_two_results.http')))

    @info = AffiliNetResponse.new(:gtin => @gtin)
    @info.get
  end

  it "should extract name" do
    @info.name_uncached.should == "Jonathan Safran Foer: Tiere Essen"
  end

  it "should return true for found" do
    @info.should be_found
  end

  it "should have a name" do
    @info.name.should == "Jonathan Safran Foer: Tiere Essen"
  end

  it "should have a image_url" do
    @info.image_url.should == "http://images90.affili.net/001152/8/433F21CC048BDC1FB345958AB71C7D78.jpg"
  end

  it "should have a url" do
    @info.url.should == "http://partners.webmasterplan.com/click.asp?ref=524680&site=6036&type=text&tnb=70&subid=&diurl=http://www.buch.de/shop/show/rubrikartikel/ID20806046.html"
  end

  it "should have a shopname" do
    @info.shopname.should == "buch.de - Bücher"
  end
end


describe AffiliNetResponse, "no result" do
  before(:each) do
    @gtin = "1234"
    stub_logon
    stub_product_services_wsdl

    stub_request(:post, "https://api.affili.net/V2.0/ProductServices.svc").
      to_return(File.read(::Rails.root.join('features/fixtures/affili_net_no_result.http')))

    @info = AffiliNetResponse.new(:gtin => @gtin)
    @info.get
  end

  it "should set found to false" do
    @info.should_not be_found
  end
  
  it "should not fail when caching attributes" do
    lambda {
      @info.cache_attributes
    }.should_not raise_error

    @info.name.should be_nil
    @info.image_url.should be_nil
  end
end
