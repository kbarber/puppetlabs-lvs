Puppet::Type.newtype(:keepalived_vrrp_instance) do
  @doc = "Type for managing vrrp_instance entries for keepalived"

  require 'ipaddr'

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "Name of vrrp_instance"

    isnamevar

    validate do |value|
      # Name must contain alphanumerics, hyphens, underscores or periods
      raise ArgumentError, "Invalid instance name #{value.inspect}" unless /^[\w\d\-_\.]+$/.match(value)
    end
  end

  newproperty(:interface) do
    desc "Interface for vrrp"

    validate do |value|
      # Name must contain no spaces
      raise ArgumentError, "Invalid interface name #{value.inspect}" if /\s/.match(value)
    end
  end

  newproperty(:virtual_router_id) do
    desc "virtual_router_id"

    validate do |value|
      raise ArgumentError, "Invalid virtual_router_id #{value.inspect} must be a number." unless value.class == Fixnum
    end
  end

  newproperty(:virtual_ipaddress, :array_matching => :all) do
    desc "virtual_ipaddress array"
  end

  newproperty(:lvs_sync_daemon_interface) do
    desc "lvs_sync_daemon_interface"

    validate do |value|
      # Name must contain no spaces
      raise ArgumentError, "Invalid lvs_sync_daemon_interface name #{value.inspect}" if /\s/.match(value)
    end
  end

  newproperty(:priority) do
    desc "priority"

    validate do |value|
      raise ArgumentError, "Invalid priority #{value.inspect} must be a number." unless value.class == Fixnum
    end
  end

  newproperty(:state) do
    desc "state"
    newvalues("MASTER","BACKUP")
  end

  newproperty(:dont_track_primary, :boolean => true) do
    desc "dont_track_primary"

    newvalues(:true, :false)
  end

  newproperty(:track_interface, :array_matching => :all) do
    desc "track_interface"

    validate do |value|
      # Name must contain no spaces
      raise ArgumentError, "Invalid interface name #{value.inspect}" if /\s/.match(value)
    end

  end

  newproperty(:mcast_src_ip) do
    desc "mcast_src_ip"

    validate do |value|
      value_obj = IPAddr.new(value)
      raise ArgumentError, "Invalid mcast_src_ip #{value.inspect} must be an ipv4 or ipv6 address." unless value_obj.ipv4? or value_obj.ipv6?
    end
  end

  newproperty(:garp_master_delay) do
    desc "garp_master_delay"

    validate do |value|
      raise ArgumentError, "Invalid garp_master_delay #{value.inspect} must be a number." unless value.class == Fixnum
    end
  end

  newproperty(:advert_int) do

    validate do |value|
      raise ArgumentError, "Invalid advert_int #{value.inspect} must be a number." unless value.class == Fixnum
    end
  end
  
  newproperty(:auth_type) do
    newvalues("AH", "PASS")
  end

  newproperty(:auth_pass) do
  end

  newproperty(:virtual_ipaddress_excluded) do
  end

  newproperty(:virtual_routes) do
  end

  newproperty(:nopreempt, :boolean => true) do
    newvalues(:true, :false)
  end

  newproperty(:preempt_delay) do

    validate do |value|
      raise ArgumentError, "Invalid preempt_delay #{value.inspect} must be a number." unless value.class == Fixnum
    end
  end

  newproperty(:debug, :boolean => true) do
    newvalues(:true, :false)
  end

  newproperty(:notify_master) do
  end

  newproperty(:notify_backup) do
  end

  newproperty(:notify_fault) do
  end

  newproperty(:notify_all) do
  end
end
