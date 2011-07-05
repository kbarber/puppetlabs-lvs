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

  it "should return a hash for vrrp_instance" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
vrrp_instance inside_network {
  state MASTER
  interface eth0
  dont_track_primary
  track_interface {
    eth0
    eth1
  }
  mcast_src_ip 225.1.2.3
  lvs_sync_daemon_interface eth1
  garp_master_delay 10
  virtual_router_id 51
  priority 100
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1234
  }
  virtual_ipaddress {
    192.168.200.17/24 dev eth1
    192.168.200.18/24 dev eth1
  }
  virtual_ipaddress_excluded {
    10.2.3.4/24 dev eth2
  }
  virtual_routes {
    src 192.168.100.1 to 192.168.109.0/24 via 192.168.200.254 dev eth1
    192.168.110.0/24 via 192.168.200.254 dev eth1
  }
  nopreempt
  preempt_delay 300
  debug
  notify_master "foo.sh bar"
  notify_backup "foo.sh bar"
  notify_fault "foo.sh bar"
  notify "notify.sh bar"
  smtp_alert
}
EOS
    h.should == {
      "vrrp_instance"=>{
        "inside_network"=>{
          "authentication"=>{
            "auth_type"=>"PASS", 
            "auth_pass"=>"1234"
          }, 
          "notify"=>"notify.sh bar", 
          "smtp_alert"=>"", 
          "dont_track_primary"=>"", 
          "lvs_sync_daemon_interface"=>"eth1", 
          "virtual_ipaddress"=>{
            "192.168.200.18/24"=>{
              "dev" => "eth1",
            }, 
            "192.168.200.17/24"=>{
              "dev" => "eth1",
            }
          }, 
          "notify_fault"=>"foo.sh bar", 
          "garp_master_delay"=>"10", 
          "priority"=>"100", 
          "interface"=>"eth0", 
          "nopreempt"=>"", 
          "advert_int"=>"1", 
          "notify_master"=>"foo.sh bar", 
          "notify_backup"=>"foo.sh bar", 
          "track_interface"=>{
            "eth0"=>"", 
            "eth1"=>""
          }, 
          "virtual_ipaddress_excluded"=>{
            "10.2.3.4/24"=>{
              "dev" => "eth2",
            }
          }, 
          "virtual_routes"=>[
            {
              "src"=>"192.168.100.1",
              "to" => "192.168.109.0/24",
              "via" => "192.168.200.254",
              "dev" => "eth1", 
            },
            {
              "to" => "192.168.110.0/24",
              "via" => "192.168.200.254",
              "dev" => "eth1",
            },
          ], 
          "debug"=>"", 
          "virtual_router_id"=>"51", 
          "state"=>"MASTER",
          "mcast_src_ip"=>"225.1.2.3", 
          "preempt_delay"=>"300", 
        }
      }
    }
  end

end
