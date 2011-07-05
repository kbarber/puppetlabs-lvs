#!/usr/bin/env rspec

require 'spec_helper'

describe "the augeas lense" do
  before :all do
    require 'augeas'
  end

  before :each do
  end

  it "should load" do
    Augeas::open("spec/test_data/augeas","lib/puppet/utils/keepalived/lenses", Augeas::NO_MODL_AUTOLOAD) { |aug|
      aug.transform(
        :lens => "keepalived.lns",
        :incl => "/etc/keepalived/keepalived.conf",
      ) 
      aug.load
    }
  end
end
