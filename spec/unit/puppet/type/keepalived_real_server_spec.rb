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
      :valid => [{"connect_port"=>"80", "connect_timeout"=>"3", "url"=>[{"status_code"=>"200", "path"=>"/"}], "delay_before_retry"=>"3", "type"=>"HTTP_GET", "nb_get_retry"=>"3"}],
      :invalid => ["not valid"],
    },
  }

  it_should_behave_like "a resource type", :keepalived_real_server, properties

end
