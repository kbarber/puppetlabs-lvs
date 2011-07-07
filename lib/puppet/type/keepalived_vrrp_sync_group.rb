Puppet::Type.newtype(:keepalived_vrrp_sync_group) do
  @doc = "Type for managing vrrp_sync_group entries for keepalived"

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
    desc "Name of vrrp_sync_group option"

    isnamevar
  end

  newproperty(:groups, :array_matching => :all) do
    desc "The instances for the vrrp_sync_group"
  end

  autorequire(:keepalived_vrrp_instance) do
    @parameters[:groups].value
  end

end
