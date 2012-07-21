require 'spec_helper'

describe User, "profile_url for a twitter user" do
  before(:each) do
    @user = User.make(:twitter_login => 'til', :twitter_id => 1234)
  end

  it "should say twitter for source" do
    @user.profile_url_source.should == "Twitter"
  end

  it "should link to twitter" do
    @user.profile_url.should == "http://twitter.com/til"
  end
end


describe User, "profile_url for a facebook user" do
  before(:each) do
    @user = User.make(:facebook, :facebook_id => 666666)
  end

  it "should say facebook for source" do
    @user.profile_url_source.should == "Facebook"
  end

  it "should link to facebook" do
    @user.profile_url.should == "http://www.facebook.com/profile.php?id=666666"
  end
end


describe User, "products" do
  before(:each) do
    @user = User.make
    
    @product = Product.make
  end

  it "should not include products that the user did not act on" do
    @user.products.should_not include(@product)
  end

  it "should contain products that the user commented on" do
    @user.comments.create!(:product => @product, :body => "Foo")
    
    @user.products.should include(@product)
  end
  
  it "should contain products that the user rated" do
    @product.rate!(:user => @user, :value => 'like')
    
    @user.products.should include(@product)
  end

  it "should contain products that the user scanned" do
    Scan.create!(:product => @product, :gtin => @product.gtin, :user => @user)

    @user.products.should include(@product)
  end

  it "should contain product only once even when commented on twice" do
    @user.comments.create!(:product => @product, :body => "Foo")
    @user.comments.create!(:product => @product, :body => "Foo")
    
    @user.products.should == [@product]
  end
end


describe User, "has_seen?" do
  before(:each) do
    @event = mock("an event", :created_at => 3.hours.ago)
    @user = User.make_unsaved
  end

  it "should not have seen when inbox_seen_at is not set" do
    @user.should_not have_seen(@event)
  end

  it "should not have seen when event is after latest view date" do
    @user.inbox_seen_at = 4.hours.ago

    @user.should_not have_seen(@event)
  end
  
  it "should have seen when event is older than latest view date" do
    @user.inbox_seen_at = 1.hour.ago

    @user.should have_seen(@event)
  end
end


describe User, "from_client_token" do
  before(:each) do
    @user = User.make
    @other = User.make

    @token = "abc123"

    @other.client_tokens.make
    @user.client_tokens.make(:token => @token)
    @other.client_tokens.make
  end

  it "should get user with client_token" do
    User.from_client_token(@token).should == @user
  end
end


describe User, "scans" do
  before(:each) do
    @user = User.make
    @empty_scan = @user.scans.make
    @empty_scan.update_attribute(:product, nil)
    @scan_with_product = @user.scans.make
  end

  it "should only include scans with product" do
    @user.scans.recent.should == [ @scan_with_product ]
  end
end
