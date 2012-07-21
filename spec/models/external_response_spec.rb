require 'spec_helper'

describe ExternalResponse, "complete_for?" do
  before(:each) do
    @gtin = "1234"
    ExternalResponse.types.each do |klass|
      klass.make(:gtin => @gtin)
    end
  end

  it "should be true when all services have been asked" do
    ExternalResponse.complete_for?(@gtin).should be_true
  end

  it "should be false when one service is missing" do
    AmazonDeResponse.last.destroy

    ExternalResponse.complete_for?(@gtin).should be_false
  end
end


describe ExternalResponse, "get_and_cache_all_missing" do
  before(:each) do
    @gtin = Sham.gtin
    CodecheckResponse.make(:gtin => @gtin)
  end

  it "should start a job for a missing service" do
    AmazonDeResponse.should_receive(:send_later).with(:get_and_cache, @gtin)

    ExternalResponse.get_and_cache_all_missing(@gtin)
  end
  
  it "should not start a job for service that has answer" do
    CodecheckResponse.should_not_receive(:send_later)

    ExternalResponse.get_and_cache_all_missing(@gtin)
  end
end
