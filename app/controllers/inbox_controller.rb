class InboxController < ApplicationController
  after_filter :seen, :only => :show
  
  def show
    @comments = Comment.find(:all,
      :conditions => ["comments.user_id<>? AND products_users.user_id=?", current_user, current_user],
      :joins => "JOIN products_users ON products_users.product_id=comments.product_id",
      :order => "created_at DESC",
      :limit => 30)

    @ratings = Rating.find(:all,
      :conditions => ["ratings.user_id<>? AND products_users.user_id=?", current_user, current_user],
      :joins => "JOIN products_users ON products_users.product_id=ratings.product_id",
      :order => "created_at DESC",
      :limit => 30)

    @scans = Scan.find(:all,
      :conditions => ["scans.user_id<>? AND products_users.user_id=?", current_user, current_user],
      :joins => "JOIN products_users ON products_users.product_id=scans.product_id",
      :order => "created_at DESC",
      :limit => 30)
    
    @events = (@comments + @ratings + @scans).sort_by(&:created_at).reverse
  end
  
protected
  
  def seen
    current_user.touch(:inbox_seen_at)
  end
end
