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

  it "should return a hash for static_ipaddresses" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
static_ipaddress {
  192.168.1.1/24 brd + dev eth0 scope global
  192.168.1.2/24 brd + dev eth0 scope global
}
EOS
    h.should == {
      "static_ipaddress"=>{
        "192.168.1.2/24"=>{
          "scope"=>"global", 
          "brd"=>"+", 
          "dev"=>"eth0"
        }, 
        "192.168.1.1/24"=>{
          "scope"=>"global", 
          "brd"=>"+", 
          "dev"=>"eth0"
        }
      }
    }
  end

  it "should return a hash for static_routes" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
static_routes {
  src 1.1.1.0/24 to 2.1.2.0/24 dev eth1
  src 1.1.2.0/24 to 2.1.2.0/24 via 1.3.1.1 dev eth3
}
EOS
    h.should == {
      "static_routes"=>[
        {
          "src"=>"1.1.1.0/24",
          "to"=>"2.1.2.0/24",
          "dev"=>"eth1",
        },
        {
          "src"=>"1.1.2.0/24",
          "to"=>"2.1.2.0/24",
          "via"=>"1.3.1.1",
          "dev"=>"eth3",
        },
      ]
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

  it "should return a hash for virtual_server_group" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
virtual_server_group web_servers {
  1.1.1.1 80
  192.168.200.3-10 80
  fwmark 1
  fwmark 2
}
EOS
    h.should == {
      "virtual_server_group"=>{
        "web_servers"=>{
          "192.168.200.3-10"=>"80", 
          "1.1.1.1"=>"80", 
          "fwmark"=>"2"
        }
      }
    }
  end

  it "should return a hash for virtual_server" do
    h = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
virtual_server 2.1.3.2 80 {
  delay_loop 60
  lb_algo rr
  lb_kind NAT
  persistence_timeout 30
  persistence_granuality 255.255.255.0
  protocol TCP
  ha_suspend
  virtualhost www.firewall.loc
  alpha
  omega
  quorum 3
  hysteresis 4
  quorum_up "q_up.sh 2.1.3.2"
  quorum_down "q_down.sh 2.1.3.2"
  sorry_server 1.1.1.3 80
  real_server 1.1.1.4 80 {
    weight 100
    inhibit_on_failure
    notify_up "notify.sh 1.1.1.4"
    notify_down "notify.sh 1.1.1.4"
    HTTP_GET {
      url {
        path /check.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      url {
        path /check2.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      connect_port 81
      bindto 1.1.1.6
      nb_get_retry 100
      delay_before_retry 5
    }
  }
  real_server 1.1.1.5 80 {
    weight 100
    inhibit_on_failure
    notify_up "notify.sh 1.1.1.5"
    notify_down "notify.sh 1.1.1.5"
    HTTP_GET {
      url {
        path /check.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      url {
        path /check2.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      connect_port 81
      bindto 1.1.1.6
      nb_get_retry 100
      delay_before_retry 5
    }
  }
}
EOS
    h.should == {
      "virtual_server"=>{
        "2.1.3.2|80"=>{
          "delay_loop"=>"60", 
          "virtualhost"=>"www.firewall.loc", 
          "hysteresis"=>"4", 
          "omega"=>"", 
          "quorum_down"=>"q_down.sh 2.1.3.2", 
          "ha_suspend"=>"", 
          "protocol"=>"TCP", 
          "persistence_timeout"=>"30", 
          "real_server"=>{
            "1.1.1.4:80"=>{
              "weight"=>"100", 
              "notify_down"=>"notify.sh 1.1.1.4", 
              "inhibit_on_failure"=>"", 
              "HTTP_GET"=>{
                "connect_port"=>"81", 
                "bindto"=>"1.1.1.6", 
                "url"=>{
                  "/check.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                  "/check2.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                }, 
                "delay_before_retry"=>"5", 
                "nb_get_retry"=>"100"
              }, 
              "notify_up"=>"notify.sh 1.1.1.4"
            }, 
            "1.1.1.5:80"=>{
              "weight"=>"100", 
              "notify_down"=>"notify.sh 1.1.1.5", 
              "inhibit_on_failure"=>"", 
              "HTTP_GET"=>{
                "connect_port"=>"81", 
                "bindto"=>"1.1.1.6", 
                "url"=>{
                  "/check.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                  "/check2.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                }, 
                "delay_before_retry"=>"5", 
                "nb_get_retry"=>"100"
              }, 
              "notify_up"=>"notify.sh 1.1.1.5"
            }
          }, 
          "persistence_granuality"=>"255.255.255.0", 
          "sorry_server"=>{
            "1.1.1.3"=>"80"
          }, 
          "quorum_up"=>"q_up.sh 2.1.3.2", 
          "quorum"=>"3", 
          "lb_kind"=>"NAT", 
          "alpha"=>"", 
          "lb_algo"=>"rr"
        }
      }
    }
  end
end

describe "the hash_to_config function" do
  before :all do
    require 'puppet/util/keepalived'
  end

  it "should return config for global_defs hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
      "global_defs" => {
        "notification_email_from" => "admin@example2.com", 
        "router_id" => "lb1.vms.cloud.bob.sh", 
        "notification_email" => {
          "admin@example1.com" => ""
        }
      } 
    })

    h.should == <<-EOS
global_defs {
   router_id lb1.vms.cloud.bob.sh
   notification_email {
     admin@example1.com
   }
   notification_email_from admin@example2.com
}
EOS

  end

  it "should return config for static_ipaddresses hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
      "static_ipaddress"=>{
        "192.168.1.2/24"=>{
          "scope"=>"global", 
          "brd"=>"+", 
          "dev"=>"eth0"
        }, 
        "192.168.1.1/24"=>{
          "scope"=>"global", 
          "brd"=>"+", 
          "dev"=>"eth0"
        }
      }
    })

    h.should == <<-EOS
static_ipaddress {
  192.168.1.1/24 brd + dev eth0 scope global
  192.168.1.2/24 brd + dev eth0 scope global
}
EOS

  end

  it "should return config for static_routes hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
      "static_routes"=>[
        {
          "src"=>"1.1.1.0/24",
          "to"=>"2.1.2.0/24",
          "dev"=>"eth1",
        },
        {
          "src"=>"1.1.2.0/24",
          "to"=>"2.1.2.0/24",
          "via"=>"1.3.1.1",
          "dev"=>"eth3",
        },
      ]
    })

    h.should == <<-EOS
static_routes {
  src 1.1.1.0/24 to 2.1.2.0/24 dev eth1
  src 1.1.2.0/24 to 2.1.2.0/24 via 1.3.1.1 dev eth3
}
EOS
  end

  it "should return config for a single vrrp_sync_group hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
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
    })

    h.should == <<-EOS
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

  end

  it "should return config for multiple vrrp_sync_group hashes" do
    h = Puppet::Util::Keepalived.hash_to_config({
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
    })

    h.should == <<-EOS
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

  end

  it "should return config for vrrp_instance hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
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
    })

    h.should == <<-EOS
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

  end

  it "should return config for virtual_server_group hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
      "virtual_server_group"=>{
        "web_servers"=>{
          "192.168.200.3-10"=>"80", 
          "1.1.1.1"=>"80", 
          "fwmark"=>"2"
        }
      }
    })

    h.should == <<-EOS
virtual_server_group web_servers {
  1.1.1.1 80
  192.168.200.3-10 80
  fwmark 1
  fwmark 2
}
EOS
  end

  it "should return config for virtual_server hash" do
    h = Puppet::Util::Keepalived.hash_to_config({
      "virtual_server"=>{
        "2.1.3.2|80"=>{
          "delay_loop"=>"60", 
          "virtualhost"=>"www.firewall.loc", 
          "hysteresis"=>"4", 
          "omega"=>"", 
          "quorum_down"=>"q_down.sh 2.1.3.2", 
          "ha_suspend"=>"", 
          "protocol"=>"TCP", 
          "persistence_timeout"=>"30", 
          "real_server"=>{
            "1.1.1.4:80"=>{
              "weight"=>"100", 
              "notify_down"=>"notify.sh 1.1.1.4", 
              "inhibit_on_failure"=>"", 
              "HTTP_GET"=>{
                "connect_port"=>"81", 
                "bindto"=>"1.1.1.6", 
                "url"=>{
                  "/check.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                  "/check2.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                }, 
                "delay_before_retry"=>"5", 
                "nb_get_retry"=>"100"
              }, 
              "notify_up"=>"notify.sh 1.1.1.4"
            }, 
            "1.1.1.5:80"=>{
              "weight"=>"100", 
              "notify_down"=>"notify.sh 1.1.1.5", 
              "inhibit_on_failure"=>"", 
              "HTTP_GET"=>{
                "connect_port"=>"81", 
                "bindto"=>"1.1.1.6", 
                "url"=>{
                  "/check.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                  "/check2.php" => {
                    "status_code"=>"5", 
                    "digest"=>"9b3a0c85a887a256d6939da88aabd8cd", 
                  },
                }, 
                "delay_before_retry"=>"5", 
                "nb_get_retry"=>"100"
              }, 
              "notify_up"=>"notify.sh 1.1.1.5"
            }
          }, 
          "persistence_granuality"=>"255.255.255.0", 
          "sorry_server"=>{
            "1.1.1.3"=>"80"
          }, 
          "quorum_up"=>"q_up.sh 2.1.3.2", 
          "quorum"=>"3", 
          "lb_kind"=>"NAT", 
          "alpha"=>"", 
          "lb_algo"=>"rr"
        }
      }
    })

    h.should == <<-EOS
virtual_server 2.1.3.2 80 {
  delay_loop 60
  lb_algo rr
  lb_kind NAT
  persistence_timeout 30
  persistence_granuality 255.255.255.0
  protocol TCP
  ha_suspend
  virtualhost www.firewall.loc
  alpha
  omega
  quorum 3
  hysteresis 4
  quorum_up "q_up.sh 2.1.3.2"
  quorum_down "q_down.sh 2.1.3.2"
  sorry_server 1.1.1.3 80
  real_server 1.1.1.4 80 {
    weight 100
    inhibit_on_failure
    notify_up "notify.sh 1.1.1.4"
    notify_down "notify.sh 1.1.1.4"
    HTTP_GET {
      url {
        path /check.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      url {
        path /check2.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      connect_port 81
      bindto 1.1.1.6
      nb_get_retry 100
      delay_before_retry 5
    }
  }
  real_server 1.1.1.5 80 {
    weight 100
    inhibit_on_failure
    notify_up "notify.sh 1.1.1.5"
    notify_down "notify.sh 1.1.1.5"
    HTTP_GET {
      url {
        path /check.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      url {
        path /check2.php
        digest 9b3a0c85a887a256d6939da88aabd8cd
        status_code 5
      }
      connect_port 81
      bindto 1.1.1.6
      nb_get_retry 100
      delay_before_retry 5
    }
  }
}
EOS

  end
end
