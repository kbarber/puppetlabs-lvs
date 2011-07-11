#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:keepalived_vrrp_sync_group) do

  properties = {
    :name => {
      :valid => ["VG1","VG2"],
      :invalid => ["not valid"],
    },
    :ensure => {
      :valid => [:present,:absent],
      :invalid => ["not valid"],
    },
    :group => {
      :valid => [["VI1","VI2"], ["VI3"], ["VI5","VI1"]],
      :invalid => ["not valid"],
    },
    :notify_master => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :notify_backup => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :notify_fault => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :notify => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :smtp_alert => {
      :valid => [true,false],
      :invalid => ["not valid"],
    },
  }

  it_should_behave_like "a resource type", :keepalived_vrrp_sync_group, properties

end
