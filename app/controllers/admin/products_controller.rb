class NotFoundInfo
  include Singleton

  def found?
    false
  end
end

class Admin::ProductsController < ApplicationController

  before_filter :require_admin

  def index
    @products = Product.paginate(:page => params[:page], :order => "created_at DESC")
    
    @headers = %w[ Cdchk AffR AmzUs AmzDe AmzUk AmzFr AmzJp Oean AffL Best Upc ]

    @products_and_sources = @products.map do |product|
      sources = [CodecheckResponse, AffiliNetResponse, AmazonUsResponse, AmazonDeResponse, AmazonUkResponse, 
        AmazonFrResponse, AmazonJpResponse, OpeneanResponse].map do |klass|
        klass.find_by_product_id(product.id) || NotFoundInfo.instance
      end

      sources += [AffiliNetInfo, BestbuyInfo, UpcDatabaseInfo].map do |klass|
        klass.find_by_product_id(product.id) || NotFoundInfo.instance
      end

      [product, sources]
    end
  end

  def show
    @product = Product.find_by_key(params["id"])
  end
end
