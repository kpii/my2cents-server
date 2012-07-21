# See how all your routes lay out with "rake routes"
ActionController::Routing::Routes.draw do |map|

  map.resources :products, :requirements => { :id => Regexp.new(Product::KEY_FORMAT) } do |products|
    products.resource :rating
  end

  map.resources :comments, :collection => { :recent => :get }

  map.resources :users

  map.resource :me, :controller => "me"

  map.resources :scans, :member => { :options => :get }

  map.resource :inbox, :controller => "inbox"

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.resource :session
  map.oauth_callback '/oauth_callback', :controller => 'sessions', :action => 'oauth_callback'

  map.with_options(:controller => 'sessions') do |auth|
    auth.connect '/auth/success', :action => 'success'
    auth.connect '/auth/failure', :action => 'failure'
  end

  map.namespace :admin do |admin| 
    admin.resources :products 
  end 

  map.with_options(:controller => 'facebook') do |fb|
    fb.facebook_login '/facebook/login', :action => 'login'
    fb.facebook_callback '/facebook/callback', :action => 'callback'
  end

  map.root :controller => "root"

  %w[ about feedback download ].each do |action|
    map.send(action, "/#{action}", :controller => "the", :action => action)
  end

  map.connect ':id', :controller => "products", :action => "show",
    :requirements => { :id => Regexp.new(Product::KEY_FORMAT) }

  map.connect '/apidoc', :controller => "apidoc", :action => "index"
  map.connect '/apidoc/show', :controller => "apidoc", :action => "show"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
