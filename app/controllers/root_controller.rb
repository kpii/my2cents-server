class RootController < ApplicationController

  def index
    @products = Product.find(:all, 
      :conditions => "EXISTS(SELECT 1 FROM comments WHERE product_id=products.id)",
      :order => "updated_at DESC",
      :limit => 10)
  end
end
