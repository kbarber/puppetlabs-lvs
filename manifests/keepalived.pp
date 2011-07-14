# TODO
#
# == Parameters
#
# [global_defs]
#   *Optional* A hash that will be passed to keepalived_global_defs.
# [global_defs_purge]
#   *Optional* Purge resources.
# [static_routes]
#   *Optional* A hash that will be passed to keepalived_static_routes.
# [static_routes_purge]
#   *Optional* Purge resources.
# [vrrp_sync_group]
#   *Optional* A hash that will be passed to keepalived_vrrp_sync_group.
# [vrrp_sync_purge]
#   *Optional* Purge resources.
# [vrrp_instances]
#   *Optional* A hash that will be passed to keepalived_instances.
# [vrrp_instances_purge]
#   *Optional* Purge resources.
# [virtual_server]
#   *Optional* A hash that will be passed to keepalived_virtual_server.
# [virtual_server_purge]
#   *Optional* Purge resources.
# [real_server]
#   *Optional* A hash that will be passed to keepalived_real_server.
# [real_server_purge]
#   *Optional* Purge resources.
#
# == Variables
#
# N/A
#
# == Examples
#
# Basic configuration: TODO
#
# == Authors
#
# Puppet Labs <info@puppetlabs.com>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class lvs::keepalived (
  $global_defs = undef,
  $global_defs_purge = false,
  $static_routes = undef,
  $static_routes_purge = false,
  $vrrp_sync_group = undef,
  $vrrp_sync_group_purge = false,
  $vrrp_instance = undef,
  $vrrp_instance_purge = false,
  $virtual_server = undef,
  $virtual_server_purge = false,
  $real_server = undef,
  $real_server_purge = false
  ) {
    
  ############
  # Packages #
  ############
  package { "keepalived":
    ensure => installed,
  }

  ###############
  # Base config #
  ###############
  file { "/etc/keepalived/keepalived.conf":
    content => template("${module_name}/keepalived.conf"),
    owner => "root",
    group => "root",
    mode => "0600",
    replace => false,
    require => Package["keepalived"],
  }

  ###########
  # Service #
  ###########
  service { "keepalived":
    ensure => running,
    enable => true,
    hasstatus => false,
    hasrestart => true,
    subscribe => File["/etc/keepalived/keepalived.conf"],
  }

  ##########
  # Lenses #
  ##########
   
  # Create storage area for libraries and lenses
  file { ["/var/lib/puppet/modules","/var/lib/puppet/modules/${module_name}"]:
    ensure => directory,
  }

  file { "/var/lib/puppet/modules/${module_name}/augeas_lenses":
    ensure => directory,
    source => "puppet:///modules/${module_name}/lenses",
    recurse => true,
    purge => true,
  }
  
  #############
  # Resources #
  #############
  if($global_defs_purge == true) {
    resources { "global_defs":
      purge => true,
    }
  }
  if($global_defs) {
    create_resources("global_defs", $global_defs)
  }
  
  if($static_routes_purge == true) {
    resources { "static_routes":
      purge => true,
    }
  }
  if($static_routes) {
    create_resources("static_routes", $static_routes)
  }

  if($vrrp_sync_group_purge == true) {
    resources { "vrrp_sync_group":
      purge => true,
    }
  }
  if($vrrp_sync_group) {
    create_resources("vrrp_sync_group", $vrrp_sync_group)
  }
  
  if($vrrp_instance_purge == true) {
    resources { "vrrp_instance":
      purge => true,
    }
  }
  if($vrrp_instance) {
    create_resources("vrrp_instance", $vrrp_instance)
  }
  
  if($virtual_server_purge == true) {
    resources { "virtual_server":
      purge => true,
    }
  }
  if($virtual_server) {
    create_resources("virtual_server", $virtual_server)
  }

  if($real_server_purge == true) {
    resources { "real_server":
      purge => true,
    }
  }
  if($real_server) {
    create_resources("real_server", $real_server)
  }
  
}
