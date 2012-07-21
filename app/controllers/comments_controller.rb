class CommentsController < ApplicationController

  before_filter :require_admin, :only => :destroy
  before_filter :modify_legacy_product_key, :only => [ :create ]

  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html do
        render
      end

      format.json do
        render :json => @comment.to_json 
      end
    end
  end

  def index
    @comments = Comment.paginate(:page => params[:page], :order => "created_at DESC")

    respond_to do |format|
      format.html
      format.json do
        render :json => @comments
      end
    end
  end

  def recent
    @comments = Comment.find(:all, :order => "created_at DESC", :limit => 10)
    if stale?(:etag => @comments)
      respond_to do |format|
        format.html do
          render :partial => 'comments/list', :object => @comments, :layout => false
        end
        format.json do
          render :json => @comments
        end
      end
    end
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(params[:comment])
    ensure_current_user_is_saved
    @comment.user = current_user
    @comment.body = nil if @comment.spam?
    
    respond_to do |format|
      if @comment.save
        if @comment.user && params["publish_to_twitter"] == "1"
          @comment.publish_to_twitter!
        end

        @comment.product.wait_for_infos

        format.html do
          if request.xhr?
            render :partial => 'comments/one'
          else
            flash[:notice] = 'Thank you!'
            redirect_to(product_path(@comment.product))
          end
        end
        format.json { render :json => @comment, :status => :created }
      else
        format.html do 
          if request.xhr?
            render :nothing => true
          else
            redirect_to(product_path(@comment.product))
          end
        end
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])

    @comment.destroy

    flash[:notice] = "The comment has been deleted"
    redirect_to product_path(@comment.product)
  end

protected
  def modify_legacy_product_key
    return unless client_app?

    if params[:comment][:product_key] =~ /^\d+$/
      product = Product.find_by_gtin!(params[:comment][:product_key])
      params[:comment][:product_key] = product.key
    end
  end

  def verify_authenticity_token
    verified_request? || render(:text => "Bad Request", :status => :bad_request)
  end
end
