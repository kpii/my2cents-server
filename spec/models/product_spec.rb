require 'spec_helper'

describe Product, "create with gtin" do
  
  it "should set the key to gtin dash id" do
    @product = Product.create!(:gtin => "1234567890128", :name => "Seife")
    
    @product.key.should == "1234567890128-#{@product.id}"
  end
end


describe Product, "short_url" do
  before(:each) do
    @product = Product.make
  end

  it "should use the m2c.at host" do
    @product.short_url.should =~ /^http:\/\/m2c.at\//
  end
  
  it "should append base62 encoded id" do
    @product.short_url.should =~ /#{Base62.encode(@product.id)}$/
  end
end


describe Product, "with a long name" do
  
  it "should truncate on creation" do
    product = Product.make_unsaved(:name => "a" * 300)
    product.save!
    
    product.name.length.should == 255
  end
  
  it "should truncate on update" do
    product = Product.make
    
    product.name = "a" * 300
    product.save!

    product.reload.name.length.should == 255
  end
end


describe Product, "rate!" do
  before(:each) do
    @user = User.make
    @product = Product.make
  end

  it "should create rating when not exists" do
    lambda {
      @product.rate!(:value => 'like', :user => @user)
    }.should change(@product.ratings.likes, :count).by(1)
  end

  it "should update rating when there is already a rating" do
    @product.rate!(:value => 'like', :user => @user)

    lambda {
      lambda {
        @product.rate!(:value => 'dislike', :user => @user)
      }.should change(@product.ratings.dislikes, :count).by(1)
    }.should change(@product.ratings.likes, :count).by(-1)
  end

  it "should destroy rating when set to blank" do
    @product.rate!(:value => 'like', :user => @user)

    lambda {
      @product.rate!(:value => '', :user => @user)
    }.should change(Rating, :count).by(-1)
  end
  
  it "should return existing rating when value is set" do
    rating = @product.rate!(:value => 'like', :user => @user)
    
    rating.value.should == 'like'
    rating.should_not be_new_record
  end
  
  it "should return new rating when value is not set" do
    rating = @product.rate!(:value => '', :user => @user)
    
    rating.should be_new_record
  end
end


describe Product, "wait_for_infos" do
  before(:each) do
    silence_warnings { Product::INFO_TIMEOUT = 8 }
    @product = Product.make
    
    @slept = 0

    Kernel.stub!(:sleep).and_return do |seconds|
      @slept += seconds
      raise Timeout::Error if @slept >= Product::INFO_TIMEOUT
    end
  end

  it "should return self immediately when infos are available" do
    @product.stub!(:info_available?).and_return(true)
    @product.stub!(:all_jobs_finished?).and_return(false)

    Kernel.should_not_receive(:sleep)

    @product.wait_for_infos.should == @product
  end
  
  it "should return self immediately when no jobs are active" do
    @product.stub!(:info_available?).and_return(false)
    @product.stub!(:all_jobs_finished?).and_return(true)
    
    Kernel.should_not_receive(:sleep)

    @product.wait_for_infos.should == @product
  end
  
  it "should return self after timeout when no info available" do
    @product.stub!(:info_available?).and_return(false)
    @product.stub!(:all_jobs_finished?).and_return(false)

    Kernel.should_receive(:sleep).at_least(5).times

    @product.wait_for_infos.should == @product
  end
  
  it "should reload the product" do
    @product.stub!(:info_available?).and_return(false)
    @product.stub!(:all_jobs_finished?).and_return(false)

    @product.should_receive(:reload).at_least(:once)

    @product.wait_for_infos.should == @product
  end
  
  it "should pass through exceptions" do
    @product.stub!(:info_available?).and_raise(ArgumentError)

    lambda {
      @product.wait_for_infos
    }.should raise_error(ArgumentError)
  end
end


describe Product, "as_json" do
  before(:each) do
    @product = Product.make
  end

  it "should not fail" do
    lambda {
      @product.as_json
    }.should_not raise_error
  end
  
  it "should include the product key" do
    @product.as_json['product']['key'].should_not be_nil
    @product.as_json['product']['key'].should == @product.key
  end

  it "should not include id" do
    @product.as_json['product']['id'].should be_nil
  end
end


describe Product, "create_missing" do
  before(:each) do
    @gtin = Sham.gtin
  end

  context "when there are no responses" do
    
    it "should not create anything" do
      lambda {
        Product.create_missing(@gtin)
      }.should_not change(Product, :count)
    end
  end
  

  context "when there is a response" do
    before(:each) do
      CodecheckResponse.make(:gtin => @gtin, :name => "Yoghurt")
    end
    
    it "should create a product" do
      Product.create_missing(@gtin)
      
      Product.count.should == 1
      Product.first.name.should == "Yoghurt"
    end
  end
  
  context "when there are several different responses" do
    before(:each) do
      CodecheckResponse.make(:gtin => @gtin, :name => "Yoghurt")
      AmazonDeResponse.make(:gtin => @gtin, :name => "Ein Buch")
    end

    it "should create a product for each response" do
      Product.create_missing(@gtin)
      
      Product.count.should == 2
      Product.all.map(&:name).sort.should == ["Ein Buch", "Yoghurt"]
    end
  end
  
  
  context "when called several times" do
    before(:each) do
      @cdchk = CodecheckResponse.make(:gtin => @gtin, :name => "Yoghurt")
    end

    it "should not create the same products again" do
      Product.create_missing(@gtin)
      Product.create_missing(@gtin)

      Product.count.should == 1
    end
    
    it "should set sources" do
      Product.create_missing(@gtin)
      Product.create_missing(@gtin)

      Product.first.sources.should == [@cdchk]
    end
  end
  
  context "with similar named responses" do
    before(:each) do
      @amzde = AmazonDeResponse.make(:gtin => @gtin, :name => "Bitterness the Star")
      @amzfr = AmazonFrResponse.make(:gtin => @gtin, :name => "Bitterness the Star")
    end

    it "should only create one product" do
      Product.create_missing(@gtin)

      Product.count.should == 1
      Product.first.name.should == "Bitterness the Star"
    end
    
    it "should set sources accordingly" do
      Product.create_missing(@gtin)

      Product.first.sources.size.should == 2
      Product.first.sources.should include(@amzde)
      Product.first.sources.should include(@amzfr)
    end
  end
end


describe Product, "create_missing for upc_database" do
  before(:each) do
    @gtin = Sham.gtin
    @upc_database_info = UpcDatabaseInfo.make(:gtin => @gtin, :name => 'Orange Juice')
  end

  it "should create product" do
    Product.create_missing(@gtin)
    
    Product.first.name.should == 'Orange Juice'
  end

  it "should create product only once" do
    Product.create_missing(@gtin)
    Product.create_missing(@gtin)
    
    Product.count.should == 1
  end
  
  it "should set source accordingly" do
    Product.create_missing(@gtin)
    
    Product.first.sources.should == [@upc_database_info]
  end
end


describe Product, "amazon_source" do
  before(:each) do
    @product = Product.make

    AmazonUsResponse.make(:product => @product, :gtin => @product.gtin)
    @latest = AmazonUsResponse.make(:product => @product, :gtin => @product.gtin)
  end
  
  it "should return the latest amazon response" do
    @product.amazon_source.should == @latest
  end
end


describe Product, "codecheck_source" do
  before(:each) do
    @product = Product.make

    CodecheckResponse.make(:product => @product, :gtin => @product.gtin)
    @latest = CodecheckResponse.make(:product => @product, :gtin => @product.gtin)
  end
  
  it "should return the latest codecheck response" do
    @product.codecheck_source.should == @latest
  end
end


describe Product, "make_sure_there_is_at_least_one" do
  before(:each) do
    @gtin = Sham.gtin
  end

  context "when there is no product" do
    
    it "should create an unknown product" do
      Product.make_sure_there_is_at_least_one(@gtin)
      
      Product.find_all_by_gtin(@gtin).size.should == 1
      Product.find_by_gtin(@gtin).name.should == "Unknown Product (#{@gtin})"
    end
    
    it "should not set a source for the unknown product" do
      Product.make_sure_there_is_at_least_one(@gtin)

      Product.first.sources.should be_empty
    end
  end
  
  context "when there is a product already" do
    before(:each) do
      Product.make(:gtin => @gtin)
    end
    
    it "should not create a product" do
      lambda {
        Product.make_sure_there_is_at_least_one(@gtin)
      }.should_not change(Product, :count)
    end
  end
end


describe Product, "sources" do
  before(:each) do
    @gtin = Sham.gtin
    @upc_database_info = UpcDatabaseInfo.make(:gtin => @gtin)
    @amazon_de_response = AmazonDeResponse.make(:gtin => @gtin)
    @product = Product.make(:gtin => @gtin)
  end

  it "should have multiple sources" do
    @upc_database_info.update_attribute(:product, @product)
    @amazon_de_response.update_attribute(:product, @product)
    
    @product.sources.count.should == 2
  end
end


describe Product, "sorting" do
  before(:each) do
    @gtin = Sham.gtin

    @product_1 = Product.make
    @product_2 = Product.make
    @product_3 = Product.make
    @product_4 = Product.make
    
    CodecheckResponse.make(:product => @product_1, :gtin => @gtin)
    UpcDatabaseInfo.make(:product => @product_1, :gtin => @gtin)
    AmazonDeResponse.make(:product => @product_2, :gtin => @gtin)
    BestbuyInfo.make(:product => @product_3, :gtin => @gtin)
    @product_4.update_attribute(:user_updated_at, Time.now)
  end

  it "should sort products with more important sources first" do
    [ @product_3, @product_1, @product_2 ].sort.
      should == [ @product_1, @product_2, @product_3 ]
  end

  it "should sort products with user updates first" do
    [ @product_3, @product_1, @product_2, @product_4 ].sort.
      should == [ @product_4, @product_1, @product_2, @product_3 ]
  end

end
