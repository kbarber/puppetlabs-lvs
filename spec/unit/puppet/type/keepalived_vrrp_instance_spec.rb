#!/usr/bin/env rspec
require 'spec_helper'
require 'unit/puppet/type/shared'

describe Puppet::Type.type(:keepalived_vrrp_instance) do

  properties = {
    :name => {
      :valid => ["VI1","VI2"],
      :invalid => ["not valid"],
    },
    :ensure => {
      :valid => [:present,:absent],
      :invalid => [:clowns],
    },
    :state => {
      :valid => ["MASTER","BACKUP"],
      :invalid => ["", "foo"],
    },
    :interface => {
      :valid => ["eth0", "vlan1", "br0"],
      :invalid => ["not valid"],
    },
    :dont_track_primary => {
      :valid => [true, false],
      :invalid => ["not valid"],
    },
    :track_interface => {
      :valid => [true, false],
      :invalid => ["not valid"],
    },
    :mcast_src_ip => {
      :valid => ["224.1.1.1"],
      :invalid => ["not valid"],
    },
    :lvs_sync_daemon_interface => {
      :valid => ["eth0", "vlan1", "br0"],
      :invalid => ["not valid"],
    },
    :garp_master_delay => {
      :valid => [10, 5, 7],
      :invalid => ["not valid"],
    },
    :virtual_router_id => {
      :valid => [50,100,150],
      :invalid => ["not valid"],
    },
    :priority => {
      :valid => [100,50,75],
      :invalid => ["not valid"],
    },
    :advert_int => {
      :valid => [1,2,3],
      :invalid => ["not valid"],
    },
    :auth_type => {
      :valid => ["AH","PASS"],
      :invalid => ["not valid"],
    },
    :auth_pass => {
      :valid => ["mypassword","$(*&%$()*&"],
      :invalid => [],
    },
    :virtual_ipaddress => {
      :valid => ["1.1.1.0"],
      :invalid => ["not valid"],
    },
    :virtual_ipaddress_excluded => {
      :valid => ["1.1.1.0"],
      :invalid => ["not valid"],
    },
    :virtual_routes => {
      :valid => ["1.1.1.0/24"],
      :invalid => ["not valid"],
    },
    :nopreempt => {
      :valid => [true,false],
      :invalid => ["not valid"],
    },
    :preempt_delay => {
      :valid => [1,2,3],
      :invalid => ["not valid"],
    },
    :debug => {
      :valid => [true,false],
      :invalid => ["not valid"],
    },
    :notify_master => {
      :valid => ["/tmp/notify.sh"],
      :invalid => [],
    },
    :notify_backup => {
      :valid => ["/tmp/notify.sh"],
      :invalid => [],
    },
    :notify_fault => {
      :valid => ["/tmp/notify.sh"],
      :invalid => [],
    },
    :notify => {
      :valid => ["/tmp/notify.sh"],
      :invalid => [],
    },
  }

  it_should_behave_like "a resource type", :keepalived_vrrp_instance, properties

end
