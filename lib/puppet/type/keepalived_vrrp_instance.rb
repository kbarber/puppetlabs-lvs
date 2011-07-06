Puppet::Type.newtype(:keepalived_vrrp_instance) do
  @doc = "Type for managing vrrp_instance entries for keepalived"

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
  end

  newproperty(:interface) do
    desc "Interface for vrrp"
  end

  newproperty(:virtual_router_id) do
    desc "virtual_router_id"
  end

  newproperty(:virtual_ipaddress, :array_matching => :all) do
    desc "virtual_ipaddress array"
  end

  newproperty(:lvs_sync_daemon_interface) do
    desc "lvs_sync_daemon_interface"
  end

  newproperty(:priority) do
    desc "priority"
  end
end
