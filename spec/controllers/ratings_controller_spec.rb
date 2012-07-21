require 'spec_helper'

describe RatingsController, "update as xhr" do
  integrate_views

  before(:each) do
    @product = Product.make

    xhr :put, :update, { :rating => { :value => 'like' }, :product_id => @product.key }
  end

  it "should return an html fragment" do
    response.should_not be_redirect
    response.should_not have_tag("html")
  end
  
  it "should return update rating counts" do
    response.should have_tag("p", /1 Like/)
    response.should have_tag("p", /0 Dislikes/)
  end
  
  it "should include sentence what the user likes" do
    response.should have_tag("p", "You like this product")
  end
end
