require 'spec_helper'

describe SortedSource, "sorting by importance" do
  
  it "should sort CodecheckInfo before AmazonUsInfo" do
    [AmazonUsResponse.new, CodecheckResponse.new].sort.first.class.
      should == CodecheckResponse
  end
  
  it "should sort amazon infos by preferred locales" do
    [AmazonJpResponse.new, AmazonUkResponse.new, AmazonUsResponse.new,
      AmazonDeResponse.new, AmazonFrResponse.new].sort.
      map { |i| i.locale }.should == %w[ us de uk fr jp ]
  end

  it "should sort AmazonJpResponse before OpeneanResponse" do
    [OpeneanResponse.new, AmazonJpResponse.new].sort.first.class.
      should == AmazonJpResponse
  end

  it "should sort AmazonJpResponse before BestbuyInfo" do
    [BestbuyInfo.make_unsaved, AmazonJpResponse.new].sort.first.class.
      should == AmazonJpResponse
  end

  it "should sort AmazonJpResponse before UpcDatabaseInfo" do
    [UpcDatabaseInfo.make_unsaved, AmazonJpResponse.new].sort.first.class.
      should == AmazonJpResponse
  end
end
