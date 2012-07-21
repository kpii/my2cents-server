require 'spec_helper'

describe AmazonUsResponse do
  before(:each) do
    @gtin = "12345"
    stub_request(:get, %r{^http://ecs.amazonaws.com/onca/xml\?.*ItemId=#{@gtin}.*}).
      to_return(File.new(::Rails.root.join('features/fixtures/amazon_lookup.http')))
  end

  it "should serialize the body of stored responses" do
    AmazonUsResponse.get_and_cache(@gtin)
    
    AmazonUsResponse.first.reload.body.should_not be_a(String)
  end
end


describe AmazonUsResponse, "looking up an ambiguous number" do
  before(:each) do
    @gtin = "666"
    stub_request(:get, %r{^http://ecs.amazonaws.com/onca/xml\?.*ItemId=#{@gtin}.*}).
      to_return(File.new(::Rails.root.join('features/fixtures/amazon_lookup_666.http')))
  end
  
  it "should not be used as a found result" do
    @response = AmazonUsResponse.new(:gtin => @gtin)
    @response.get

    @response.should_not be_found
  end
end

describe AmazonUsResponse, "looking up a GTIN for which Amazon has no info" do
  before(:each) do
    @gtin = "1000000000001"
    stub_request(:get, %r{^http://ecs.amazonaws.com/onca/xml\?.*ItemId=#{@gtin}.*}).
      to_return(File.new(::Rails.root.join('features/fixtures/amazon_not_found.http')))
  end

  it "should not raise an error" do
    @response = AmazonUsResponse.new(:gtin => @gtin)
    lambda {
      @response.get
    }.should_not raise_error()
  end

  it "should return nil" do
    @response = AmazonUsResponse.new(:gtin => @gtin)
    @response.get

    @response.body.should be_nil
    @response.should_not be_found
  end

end
