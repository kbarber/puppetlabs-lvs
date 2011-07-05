#!/usr/bin/env ruby

require 'puppet'
require 'puppet/util/keepalived'

a = Puppet::Util::Keepalived.config_to_hash(<<-EOS)
global_defs {
   router_id lb1.vms.cloud.bob.sh
   notification_email {
     admin@example1.com
   }
   notification_email_from admin@example2.com
}
EOS

p a
