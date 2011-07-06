Puppet::Type.newtype(:keepalived_static_routes) do
  @doc = "Type for managing static_routes entries for keepalived"

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
    desc "Name of static_routes option in the form src|destination"

    isnamevar
  end

  newproperty(:dev) do
    desc "The device to route to"
  end

  newproperty(:via) do
    desc "The IP address to route to"
  end

end
