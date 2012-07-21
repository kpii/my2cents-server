require 'spec_helper'

describe Comment, "creation with a product_key" do
  before(:each) do
    @product_key = "1234567890128"
  end
  

  context "when the product with this key exists" do
    before(:each) do
      @product = Product.make
    end

    it "should set product to given product" do
      @comment = Comment.create!(:product_key => @product.key, :body => "Bla", :user => User.make)
      
      @comment.product.should == @product
    end
  end
  

  context "when the product with this key does not exist" do

    it "should raise an error" do
      plan = Comment.plan.merge(:product_key => "12345")
      plan.delete(:product_id)

      lambda {
        Comment.create!(plan)
      }.should raise_error
    end    
  end
end


describe Comment, "creation with a product_id" do
  before(:each) do
    Product.make
    @product = Product.make
  end

  it "should save the product" do
    @comment = Comment.make(:product_id => @product.id)
    @comment.reload

    @comment.product.should == @product
  end
end


describe Comment, "twitter_status" do
  before(:each) do
    @comment = Comment.make(:body => "a" * 130)
    @product = @comment.product
  end

  it "should not exceed 140 characters" do
    @comment.twitter_status.length.should <= 140
  end
  
  it "should append short url" do
    @comment.twitter_status.should =~ /#{@comment.product.short_url}$/
  end
  
  it "should contain product name" do
    @comment.twitter_status.should include("On #{@product.name}")
  end
end
