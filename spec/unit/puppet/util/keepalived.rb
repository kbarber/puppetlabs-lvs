#!/usr/bin/env rspec

require 'spec_helper'

describe "the get_global_defs" do

  @@data = "spec/test_data/augeas"
  @@lns = "lib/puppet/util/keepalived/lenses"

  before :all do
    require 'puppet/util/keepalived'
  end

  it "should return a list of global_defs" do
    defs = Puppet::Util::Keepalived.get_global_defs(
      lenses = "files/lenses",
      root = "spec/test_data/augeas"
    )
    defs.should == {
      "notification_email_from"=>"admin@example2.com", 
      "smtp_server"=>"127.0.0.1", 
      "smtp_connect_timeout"=>"30", 
      "router_id"=>"lb1.vms.cloud.bob.sh", 
      "notification_email"=>["admin@example1.com"],
    }
  end
end
