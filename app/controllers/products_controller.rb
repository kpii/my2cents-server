class ProductsController < ApplicationController
  before_filter :serve_legacy_product_url_to_old_clients, :only => [ :show ]
  before_filter :redirect_legacy_product_url, :only => [ :show ]

  def index
    render :text => "Sorry, nothing to see here", :status => :gone
  end 

  def show
    @product = Product.find_by_key!(params[:id])

    @comment = @product.comments.new

    @rating = @product.ratings.find(:first, :conditions => ["user_id=?", current_user.id]) ||
      @product.ratings.new

    # Force session creation for logging. This is not spec'ed because
    # in the test env the session seems to be always created anyway
    session[:dummy] = 1

    ProductRequest.create!(
      :product => @product, 
      :session_id => request.session_options[:id],
      :user_agent => request.env['HTTP_USER_AGENT'])

    respond_to do |format|
      format.html do
        render "products/show"
      end

      format.json do
        h = @product.as_detailed_json
        h["product"].merge!((@rating.as_product_json))
        render :json => h
      end
    end
  end
  
  def edit
    @product = Product.find_by_key!(params[:id])
  end
  
  def create
    attrs = params[:product].dup
    attrs[:user_updated_at] = Time.now
    @product = Product.create!(attrs)

    headers['Location'] = product_path(@product)
    render :json => @product, :status => :created
  end

  def update
    @product = Product.find_by_key!(params[:id])

    attrs = params[:product].dup
    attrs[:user_updated_at] = Time.now
    @product.update_attributes!(attrs)

    respond_to do |format|
      format.html do
        redirect_to product_path(@product), :notice => "Thank you!"
      end
      format.json do
        render :nothing => true
      end
    end
  end

protected
  def legacy_product_url?
    params[:id] =~ /^\d+$/
  end
  
  def serve_legacy_product_url_to_old_clients
    if legacy_product_url? && client_app?
      @scan = Scan.new(:gtin => params[:id])
      ensure_current_user_is_saved
      @scan.user = current_user
      @scan.save!
      
      logger.debug "The object is #{@scan}"

      @tries = 0
      while @scan.product.nil? and @tries < 15 do
        @tries += 1
        Scan.uncached {
          @scan.reload
        }
        logger.debug "The loop is #{@tries}"
        logger.debug "The scan is #{@scan}"
        logger.debug "The product is #{@scan.product}"
        Kernel.sleep 1
      end
      render :json => @scan.product.as_detailed_json
    end
  end

  def redirect_legacy_product_url
    if legacy_product_url?
      redirect_to product_path(Product.find_by_gtin!(params[:id])), :status => :moved_permanently
    end
  end
end
