require 'spec_helper'

describe Scan, "as_json" do
  before(:each) do
    @scan = Scan.make
  end

  it "should contain created_at" do
    @scan.as_json['scan']['created_at'].should_not be_nil
  end
  
  it "should contain a product with key, name and image_url" do
    product = @scan.as_json['scan']['product']
    
    product['key'].should == @scan.product.key
    product['name'].should == @scan.product.name
    product['image_url'].should == @scan.product.image_url
  end

  it "should not contain product_id" do
    @scan.as_json['scan']['product_id'].should be_nil
  end
end


describe Scan, "as_json with empty product" do
  before(:each) do
    @scan = Scan.make(:product => nil)
    @scan.product.should be_nil # sanity check
  end

  it "should have null as product" do
    @scan.as_json['scan'].should have_key('product')
    @scan.as_json['scan']['product'].should be_nil
  end
end


describe Scan, "options" do
  
  context "when there is a product" do
    before(:each) do
      @product = Product.make
      @scan = Scan.make(:gtin => @product.gtin)
    end

    it "should wrap every element with a product root element" do
      @scan.options.map(&:keys).flatten.uniq.should == [:product]
    end

    it "should include the product with name and key" do
      @scan.options.first[:product][:name].should        == @product.name
      @scan.options.first[:product][:product_key].should == @product.key
    end
  end
end


describe Scan, "collapse_options" do
  before(:each) do
    @scan = Scan.make_unsaved
  end

  it "should collapse with similar name" do
    collapsed = @scan.collapse_options([
        { :name => "abc", :source => "123" },
        { :name => "def", :source => "456" },
        { :name => "abc", :source => "789" },
    ])
    
    collapsed.should == [
      { :name => "abc", :source => "123,789" },
      { :name => "def", :source => "456" },
    ]
  end
  
  it "should keep image of first option" do
    collapsed = @scan.collapse_options([
        { :name => "abc", :image_url => "first_image", :source => "123" },
        { :name => "abc", :image_url => "second_image", :source => "456" },
    ])
    
    collapsed.should == [
      { :name => "abc", :image_url => "first_image", :source => "123,456" },
    ]    
  end
end
