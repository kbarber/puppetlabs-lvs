class lvs {
  package { "keepalived":
    ensure => installed,
  }

  file { "/etc/keepalived/keepalived.conf":
    content => template("${module_name}/keepalived.conf"),
    owner => "root",
    group => "root",
    mode => "0600",
    replace => false,
    require => Package["keepalived"],
  }

  service { "keepalived":
    ensure => running,
    enable => true,
    hasstatus => false,
    hasrestart => true,
    subscribe => File["/etc/keepalived/keepalived.conf"],
  }

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
}
