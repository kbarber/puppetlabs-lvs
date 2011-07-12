Puppet::Type.newtype(:keepalived_virtual_server) do
  @doc = "Type for managing virtual_server entries for keepalived"

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
    desc "Name of virtual_server"

    isnamevar
  end

  newproperty(:delay_loop) do
    desc "Delay loop"

    validate do |value|
      raise ArgumentError, "Invalid delay_loop #{value.inspect} must be a number." unless /^\d+$/.match(value)
    end
  end

  newproperty(:lb_algo) do
    desc "lb_algo"

    newvalues("rr","wrr","lc","wlc","lblc","sh","dh")
  end

  newproperty(:lb_kind) do
    desc "lb_kind"

    newvalues("NAT","DR","TUN")
  end

  newproperty(:persistence_timeout) do
    desc "persistence_timeout"

    validate do |value|
      raise ArgumentError, "Invalid persistence_timeout #{value.inspect} must be a number." unless /^\d+$/.match(value)
    end
  end

  newproperty(:virtualhost) do
  end

  newproperty(:sorry_server) do
  end

  newproperty(:quorum_up) do
  end

  newproperty(:quorum_down) do
  end

  newproperty(:quorum) do
  end

  newproperty(:protocol) do
    newvalues("TCP")
  end

  newproperty(:persistence_granularity) do
  end

  newproperty(:hysteresis) do
  end

  newproperty(:alpha, :boolean => true) do
    newvalues(:true, :false)
  end

  newproperty(:omega, :boolean => true) do
    newvalues(:true, :false)
  end

  newproperty(:ha_suspend, :boolean => true) do
    newvalues(:true, :false)
  end
end
