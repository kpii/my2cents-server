module SyncUserProducts
  def self.included(base)
    base.after_create :add_to_user_products
  end
  
protected
  def add_to_user_products
    user.products << product unless user.products.include?(product)
  end
end
