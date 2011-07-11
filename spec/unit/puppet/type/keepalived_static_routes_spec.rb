#!/usr/bin/env rspec
require 'spec_helper'
require 'unit/puppet/type/shared'

describe Puppet::Type.type(:keepalived_static_routes) do

  properties = {
    :name => {
      :valid => ["0.0.0.0/0|1.1.1.0/24"],
      :invalid => ["not valid"],
    },
    :ensure => {
      :valid => [:present,:absent],
      :invalid => [:pumpkin],
    },
    :dev => {
      :valid => ["eth0"],
      :invalid => ["not valid"],
    }
  }

  it_should_behave_like "a resource type", :keepalived_static_routes, properties

end
