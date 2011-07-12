#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:keepalived_real_server) do

  properties = {
    :name => {
      :valid => ["1.1.1.1|80|TCP/1.1.2.1|80", "2.2.2.2|53|UDP/1.1.2.2|53"],
      :invalid => ["not valid"],
    },
    :ensure => {
      :valid => [:present, :absent],
      :invalid => ["not valid"],
    },
    :weight => {
      :valid => ["50","100","1"],
      :invalid => ["not valid"],
    },
    :inhibit_on_failure => {
      :valid => [true, false],
      :invalid => ["not valid"],
    },
    :notify_up => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :notify_down => {
      :valid => ["/bin/notify.sh"],
      :invalid => [],
    },
    :healthcheck => {
      :valid => ["http_get","misc_check","ssl_get","smtp_check"],
      :invalid => ["not valid"],
    },
  }

  it_should_behave_like "a resource type", :keepalived_real_server, properties

end
