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

    validate do |value|
      # Name must contain alphanumerics, hyphens, underscores or periods
      raise ArgumentError, "Invalid instance name #{value.inspect}" unless /^[\w\d\-_\.]+$/.match(value)
    end
  end

  newproperty(:group, :array_matching => :all) do
    desc "The instances for the vrrp_sync_group"

    validate do |value|
      # Name must contain alphanumerics, hyphens, underscores or periods
      raise ArgumentError, "Invalid instance name #{value.inspect}" unless /^[\w\d\-_\.]+$/.match(value)
    end
  end

  newproperty(:notify_master) do
  end

  newproperty(:notify_backup) do
  end

  newproperty(:notify_fault) do
  end

  newproperty(:notify) do
  end

  newproperty(:smtp_alert, :boolean => true) do
    newvalues(:true, :false)
  end

  autorequire(:keepalived_vrrp_instance) do
    @parameters[:group].value
  end

end
