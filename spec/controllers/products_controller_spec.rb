require 'spec_helper'

describe ProductsController, "logging a product request" do
  before(:each) do
    @product = Product.make
    get :show, :id => @product.key
    
    @product_request = ProductRequest.last
  end

  it "should create a ProductRequest entry" do
    ProductRequest.count.should == 1
  end
  
  it "should store the session id in ProductRequest" do
    @product_request.session_id.should == request.session_options[:id]
  end
  
  it "should store created at" do
    @product_request.created_at.should_not be_nil
  end
  
  it "should store the user agent" do
    @product_request.user_agent.should_not be_nil
  end
end


describe ProductsController, "logging a product request with a long user agent string" do
  before(:each) do
    @product = Product.make
  end

  it "should not fail" do
    request.env['HTTP_USER_AGENT'] = "a" * 300

    lambda {
      get :show, :id => @product.key
    }.should_not raise_error
  end
end
