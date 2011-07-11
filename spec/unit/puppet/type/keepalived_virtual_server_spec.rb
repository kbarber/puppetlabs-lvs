#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:keepalived_virtual_server) do

  it "should have a 'name' parameter'" do
    Puppet::Type.type(:keepalived_virtual_server).new(:name => "VG1")[:name].should == "VG1"
  end

  properties = {
    :name => {
      :valid => ["1.1.1.1|80|TCP", "2.2.2.2|53|UDP"],
      :invalid => ["not valid"],
    },
    :ensure => {
      :valid => [:present, :absent],
      :invalid => [:nounce],
    },
    :delay_loop => {
      :valid => [5,10,15],
      :invalid => ["not valid"],
    },
    :lb_algo => {
      :valid => ["rr","wrr"],
      :invalid => ["not valid"],
    },
    :lb_kind => {
      :valid => ["NAT","DR"],
      :invalid => ["not valid"],
    },
    :persistence_timeout => {
      :valid => [60,30,15],
      :invalid => ["not valid"],
    },
    :persistence_granularity => {
      :valid => [],
      :invalid => ["not valid"],
    },
    :protocol => {
      :valid => ["TCP","UDP"],
      :invalid => ["not valid"],
    },
    :ha_suspend => {
      :valid => [true,false],
      :invalid => ["not valid"],
    },
    :virtualhost => {
      :valid => ["www.foo.com"],
      :invalid => ["not valid"],
    },
    :alpha => {
      :valid => [true,false],
      :invalid => ["not valid"],
    },
    :omega => {
      :valid => [true,false],
      :invalid => ["not valid"],
    },
    :quorum => {
      :valid => [],
      :invalid => [],
    },
    :hysteresis => {
      :valid => [],
      :invalid => [],
    },
    :quorum_up => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :quorum_down => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :sorry_server => {
      :valid => [],
      :invalid => [],
    },
  }

  it_should_behave_like "a resource type", :keepalived_virtual_server, properties

end
