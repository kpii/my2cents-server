require 'spec_helper'

describe UsersHelper, "user_profile_sentence" do
  before(:each) do
    @user = User.make(:name => 'kpi')

    2.times { @user.comments.make }

    3.times { @user.scans.make }
    
    1.times { @user.ratings.make(:value => 'like') }

    2.times { @user.ratings.make(:value => 'dislike') }
  end

  it "should have the user name" do
    helper.user_profile_sentence(@user).should match(/kpi/)
  end
  
  it "should count comments" do
    helper.user_profile_sentence(@user).should match(/2 comments/)
  end

  it "should count scans" do
    helper.user_profile_sentence(@user).should match(/scanned 3 barcodes/i)
  end
  
  it "should count likes"  do
    helper.user_profile_sentence(@user).should match(/liked 1 product/i)
  end

  it "should count dislikes"  do
    helper.user_profile_sentence(@user).should match(/disliked 2 products/i)
  end
end
