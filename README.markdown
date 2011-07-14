## puppetlabs-lvs module

### Overview

This is the Linux Virtual Server Puppet module. It provides classes and resources
for managing LVS software in Puppet.

### Disclaimer

Warning! While this software is written in the best interest of quality it has 
not been formally tested by our QA teams. Use at your own risk, but feel free 
to enjoy and perhaps improve it while you do.

Please see the included Apache Software License for more legal details 
regarding warranty.

### Installation

From github, download the module into your modulepath on your Puppetmaster. If 
you are not sure where your module path is try this command:

  puppet --configprint modulepath

Depending on the version of Puppet, you may need to restart the puppetmasterd 
(or Apache) process before the functions will work.

## Quickstart

### keepalived

Setting up a keepalived load-balancer cluster using DR (note - this example
uses exported resources, so you must enable stored configurations for this
to work):

    class my_lb {
      class { "lvs::keepalived": 
        global_defs => {
          router_id => { value => $fqdn }
        },
        static_routes => {
          '0.0.0.0/0|224.0.0.0/4' => {
            dev    => 'eth0',
            via    => '0.0.0.0',
          }
        },
        vrrp_sync_group => {
          'VG1' => {
            group => ['VI_1'],
          }
        },
        vrrp_instance => {
          'VI_1' => {
            interface                 => 'eth0',
            lvs_sync_daemon_interface => 'eth0',
            priority                  => 100,
            virtual_ipaddress         => ['10.1.2.200/24'],
            virtual_router_id         => 51,
          }
        },
        virtual_server => {
          '10.1.2.200|80|TCP' => {
            delay_loop          => 1,
            lb_algo             => 'rr',
            persistence_timeout => 60,
            lb_kind             => 'DR',
          },
        }
      }
      
      Keepalived_real_server <<| tag == "my_lb" |>> 
    }
    
    node lb1 {
      class { "my_lb": }
    }
    node lb2 {
      class { "my_lb": }
    }

    class my_web {
      $hc = {
        type => "HTTP_GET",
        connect_port       => '80',
        url                => [
          {'status_code' => 200, path => '/'}
        ],
      }
      @@keepalived_real_server { "10.1.2.200|80|TCP/${ipaddress_eth0}|80":
        ensure             => 'present',
        healthcheck        => $hc,    
        weight             => '1',
        tag                => "my_lb",
      }
    }

    node web1 {
      class { "my_web": }
    }
    node web2 {
      class { "my_web": }
    }

## Reference

### todo
