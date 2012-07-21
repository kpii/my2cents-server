require 'spec_helper'

describe Base62 do
  it "should encode and decode" do
    Base62.decode(Base62.encode(99)).should == 99
    Base62.decode(Base62.encode(0)).should == 0
  end
  
  it "should encode" do
    Base62.encode(0).should == "0"
    Base62.encode(61).should == "Z"
  end
end
