#!/usr/bin/env rspec

require 'spec_helper'

describe "the augeas lense" do

  @@data = "spec/test_data/augeas"
  @@lns = "files/lenses"

  before :all do
    require 'augeas'
  end

  it "should load" do
    Augeas::open(@@data,@@lns,Augeas::NO_MODL_AUTOLOAD) { |aug|
      aug.transform(
        :lens => "keepalived.lns",
        :incl => "/etc/keepalived/keepalived.conf"
      ) 
      aug.load
    }
  end

  it "should find config path" do
    Augeas::open(@@data,@@lns,Augeas::NO_MODL_AUTOLOAD) { |aug|
      aug.transform(
        :lens => "keepalived.lns",
        :incl => "/etc/keepalived/keepalived.conf"
      ) 
      aug.load
      node = aug.exists("/files/etc/keepalived/keepalived.conf")
      node.should == true
    }
  end
end
