require 'spec_helper'

describe OpeneanResponse, "with a body" do
  before(:each) do
    @info = OpeneanResponse.new(:body => <<-EOTXT)
<FONT COLOR='blue'>Achtung: Zu dieser EAN existieren derzeit keine weiteren Stammdaten! Sie k&ouml;nnen jedoch beim Ausbau der Datenbank mithelfen: Wenn Sie den Button 'Bearbeiten' bet&auml;tigen, haben Sie Zugriff auf den Datensatz und k&ouml;nnen z.B. einen besser passenden, allgemeinen Produktnamen vergeben und das Produkt in eine Kategorie einordnen.</FONT><BR><BR>error=0
---
name=
detailname=Poland Spring bottled water sport top (no deposit)
vendor=
maincat=
subcat=
maincatnum=-1
subcatnum=
contents=
origin=USA und Kanada
descr=700ml / 7.7 FL OZ
validated=0 %
---
EOTXT
  end

  it "should extract name from detailname when name empty" do
    @info.name_uncached.should == "Poland Spring bottled water sport top (no deposit)"
  end
end


describe OpeneanResponse, "with a name and a detailname" do
  before(:each) do
    @info = OpeneanResponse.new(:body => <<-EOTXT)
error=0
---
name=Natürliches Mineralwasser
detailname=Bad Vilbeler RIED Quelle
---
EOTXT
  end
  
  it "should use the name" do
    @info.name_uncached.should == "Natürliches Mineralwasser"
  end
end


describe OpeneanResponse, "with no body" do
  before(:each) do
    @info = OpeneanResponse.new(:body => <<-EOTXT)
error=2
---
EOTXT
  end

  it "should set found to false" do
    @info.should_not be_found
  end
  
  it "should not fail when caching attributes" do
    lambda {
      @info.cache_attributes
    }.should_not raise_error

    @info.name.should be_nil
  end
end


describe OpeneanResponse, "image_url" do
  before(:each) do
    @info = OpeneanResponse.new
  end

  it "should always be nil" do
    @info.image_url.should be_nil
  end
end


describe OpeneanResponse, "loading from non utf8 http response" do
  before(:each) do
    stub_request(:get, /.*/).
      to_return(File.read(Rails.root.join('features/fixtures/openean_9002490100070.http')))
  end
  
  it "should convert to utf8" do
    @response = OpeneanResponse.new(:gtin => "9002490100070")
    @response.get
    @response.name.should == "Red Bull with Ümlaut"
  end
end
