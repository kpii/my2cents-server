class Rating < ActiveRecord::Base
  include SyncUserProducts

  belongs_to :product
  belongs_to :user

  named_scope :likes, :conditions => "value='like'"
  named_scope :dislikes, :conditions => "value='dislike'"
  named_scope :recent, :order => "created_at DESC", :limit => 25

  def as_product_json
    { "rating" => { 
        "likes"    => product.ratings.likes.count,
        "dislikes" => product.ratings.dislikes.count,
        "me"       => value }}
  end

  def like?
    value == 'like'
  end
  
  def dislike?
    value == 'dislike'
  end
  
  def neutral?
    ! (like? || dislike?)
  end
end
