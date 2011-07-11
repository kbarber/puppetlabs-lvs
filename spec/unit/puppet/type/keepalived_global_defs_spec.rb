#!/usr/bin/env rspec
require 'spec_helper'
require 'unit/puppet/type/shared'

describe Puppet::Type.type(:keepalived_global_defs) do

  properties = {
    :name => {
      :valid => ["router_id"],
      :invalid => ["not valid"],
    },
    :ensure => {
      :valid => [:present, :absent],
      :invalid => [:flowers],
    },
    :value => {
      :valid => ["51"],
      :invalid => [],
    },
  }

  it_should_behave_like "a resource type", :keepalived_global_defs, properties

end
