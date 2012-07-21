class RatingsController < ApplicationController
  
  def update
    @product = Product.find_by_key!(params[:product_id])

    ensure_current_user_is_saved

    @rating = @product.rate!(
      :value => params[:rating][:value],
      :user => current_user)

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'products/rating'
        else
          redirect_to @product
        end
      end
      format.json do
        render :json => @rating.as_product_json
      end
    end
  end
end
