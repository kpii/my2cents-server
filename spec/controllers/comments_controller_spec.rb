require 'spec_helper'

describe CommentsController do
  integrate_views

  before(:each) do
    @product = Product.make
  end

  it "should redirect to product page when normal html request" do
    post :create, :comment => { :body => "yes", :product_key => @product.key }
    
    response.should redirect_to(product_path(@product))
  end
  
  it "should return comment fragment when xhr request" do
    xhr :post, :create, :comment => { :body => "yes", :product_key => @product.key }

    response.should_not be_redirect
    response.should_not have_tag("html")
    response.should have_tag("img.tip")
  end
end
