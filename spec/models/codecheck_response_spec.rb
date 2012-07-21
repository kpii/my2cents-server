require 'spec_helper'

describe CodecheckResponse, "successful lookup" do
  before(:each) do
    @gtin = "5411188081852"
    stub_request(:get, "https://username:xxxxxxxxx@www.codecheck.info/WebService/rest/prod/ean/7/#{@gtin}").
      to_return(File.read(::Rails.root.join('features/fixtures/codecheck_lookup.http')))
    @response = CodecheckResponse.new(:gtin => @gtin)
    @response.get
  end
  
  it "should return true for found" do
    @response.should be_found
  end

  it "should have a name" do
    @response.name.should == "alpro soya"
  end

  it "should have a image_url" do
    @response.image_url.should == "http://www.codecheck.info/img/40237/2"
  end
end


describe CodecheckResponse, "failed lookup" do
  before(:each) do
    @failure = "5411188081856"

    stub_request(:get, "https://username:xxxxxxxxx@www.codecheck.info/WebService/rest/prod/ean/7/#{@failure}").
      to_return(File.read(::Rails.root.join('features/fixtures/codecheck_not_found.http')))

    @response = CodecheckResponse.new(:gtin => @failure)
    @response.get
  end
  
  it "should not be found" do
    @response.should_not be_found
  end
end


describe CodecheckResponse, "image_url" do
  before(:each) do
    @response = CodecheckResponse.new
  end

  it "should be nil when image id is empty" do
    @response.stub!(:image_id).and_return(nil)

    @response.image_url.should be_nil
  end
end
