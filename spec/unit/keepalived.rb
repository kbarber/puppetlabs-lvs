#!/usr/bin/env rspec

require 'spec_helper'

describe "the config_to_hash function" do
  before :all do
    require 'puppet/util/keepalived'
  end

  it "should return a hash for global_defs" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
global_defs {
   router_id lb1.vms.cloud.bob.sh
   notification_email {
     admin@example1.com
   }
   notification_email_from admin@example2.com
}
EOS

    h.should == {
      "global_defs" => {
        "notification_email_from" => "admin@example2.com", 
        "router_id" => "lb1.vms.cloud.bob.sh", 
        "notification_email" => {
          "admin@example1.com" => ""
        }
      } 
    }
  end

  it "should return a hash for a single vrrp_sync_group" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
vrrp_sync_group VG_1 {
  group {
    VI_1
    VI_2
    VI_3
    VI_4
    VI_5
  }
  notify_master /path/to_master.sh
  notify_backup /path/to_backup.sh
  notify_fault "/path/fault.sh VG_1"
  smtp_alert
}
EOS

    h.should == {
      "vrrp_sync_group" => { 
        "VG_1" => {
          "group" => {
            "VI_3"=>"", 
            "VI_4"=>"", 
            "VI_5"=>"", 
            "VI_1"=>"", 
            "VI_2"=>""
          }, 
          "smtp_alert" => "", 
          "notify_fault"=>"/path/fault.sh VG_1", 
          "notify_master"=>"/path/to_master.sh",
          "notify_backup"=>"/path/to_backup.sh", 
        }
      }
    }
  end

  it "should return a hash for multiple vrrp_sync_group" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
vrrp_sync_group VG_1 {
  group {
    VI_1
    VI_2
    VI_3
    VI_4
    VI_5
  }
  notify_master /path/to_master.sh
  notify_backup /path/to_backup.sh
  notify_fault "/path/fault.sh VG_1"
  smtp_alert
}

vrrp_sync_group VG_2 {
  group {
    VI_6
    VI_7
    VI_8
    VI_9
    VI_10
  }
  notify_master /path/to_master.sh
  notify_backup /path/to_backup.sh
  notify_fault "/path/fault.sh VG_2"
  smtp_alert
}
EOS

    h.should == {
      "vrrp_sync_group" => { 
        "VG_2" => {
          "group" => {
            "VI_10"=>"", 
            "VI_6"=>"", 
            "VI_7"=>"", 
            "VI_8"=>"", 
            "VI_9"=>""
          }, 
          "smtp_alert"=>"", 
          "notify_fault"=>"/path/fault.sh VG_2", 
          "notify_master"=>"/path/to_master.sh",
          "notify_backup"=>"/path/to_backup.sh", 
        },
        "VG_1" => {
          "group" => {
            "VI_3"=>"", 
            "VI_4"=>"", 
            "VI_5"=>"", 
            "VI_1"=>"", 
            "VI_2"=>""
          }, 
          "smtp_alert"=>"", 
          "notify_fault"=>"/path/fault.sh VG_1", 
          "notify_master"=>"/path/to_master.sh",
          "notify_backup"=>"/path/to_backup.sh", 
        }
      }
    }
  end

end
